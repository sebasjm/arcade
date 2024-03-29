#!/bin/bash

DIR="$(dirname -- "${BASH_SOURCE[0]:-$0}")"
LAST_RESPONSE=`mktemp /tmp/arcade_check-XXXXXX`

#ACTIVE_ORDERS=$(find $DIR/orders -maxdepth 1 -type f -name '*.active')
ACTIVE_ORDER=$@

DB=github/arcade/pay/orders

for order in $(ssh mendoza ls $DB); do
	ORDER_ID=$(basename $order | sed 's/.active$//' )
        STATUS=$(curl https://merchant-backend.taler.ar/orders/$ORDER_ID \
                -w "%{http_code}"  \
                -s  \
                -o $LAST_RESPONSE)
	echo https://merchant-backend.taler.ar/orders/$ORDER_ID is $STATUS
	[ $STATUS != "402" ] && ssh mendoza mv $DB/$order $DB/.checked-$STATUS-$ORDER_ID
	[ $STATUS == "200" ] && shattered-pixel-dungeon
done
