#!/bin/bash

DIR="$(dirname -- "${BASH_SOURCE[0]:-$0}")"
HTTP_FOUND='HTTP/1.1 302 Found'
HTTP_OK='HTTP/1.1 200 Ok'
HTTP_ERROR='HTTP/1.1 500 Error'

TOKEN=$(cat $DIR/TOKEN)
LAST_RESPONSE=`mktemp /tmp/arcade_pay-XXXXXX`

STATUS=$(curl 'https://merchant-backend.taler.ar/instances/default/private/orders' \
	-H 'Accept: application/json, text/plain, */*' \
	-H "Authorization: Bearer secret-token:$TOKEN"  \
	-d '{"create_token":false,"order":{"amount":"ARS:1","summary":"insert coin"}}' \
	-w "%{http_code}"  \
	-s  \
	-o $LAST_RESPONSE)

if [ $STATUS != "200" ]; then
	echo "$HTTP_ERROR

Something when wrong
`cat $LAST_RESPONSE`
"
	exit 1
fi

ORDER_ID=$(jq -r .order_id $LAST_RESPONSE)

touch $DIR/orders/$ORDER_ID.active
#Location: taler://pay/merchant-backend.taler.ar/$ORDER_ID/
echo "$HTTP_FOUND
Location: https://merchant-backend.taler.ar/orders/$ORDER_ID

"

