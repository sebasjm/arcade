#!/bin/bash

DIR="$(dirname -- "${BASH_SOURCE[0]:-$0}")"
HTTP_FOUND='HTTP/1.1 302 Found'
HTTP_OK='HTTP/1.1 200 Ok'
RESERVE_ID=$(cat $DIR/RESERVE_ID)
TOKEN=$(cat $DIR/TOKEN)
LAST_RESPONSE=`mktemp /tmp/arcade_response-XXXXXX`

TOTAL=0
touch /tmp/parsed_amount
while read line; do
 TOTAL=$(($TOTAL+$line));
done < /tmp/parsed_amount 2> /dev/null
rm -f /tmp/parsed_amount

set -x
STATUS=$(curl "https://merchant-backend.taler.ar/instances/default/private/reserves/$RESERVE_ID/authorize-tip" \
	-H 'Accept: application/json, text/plain, */*'  \
	-H "Authorization: Bearer secret-token:$TOKEN"  \
	-d '{"amount":"ARS:'$TOTAL'","justification":"1","next_url":"1"}' \
	-w "%{http_code}"  \
	-s  \
	-o $LAST_RESPONSE)

TIP_URL=$(jq -r .tip_status_url $LAST_RESPONSE)

echo "
$HTTP_FOUND
Location: $TIP_URL
"

