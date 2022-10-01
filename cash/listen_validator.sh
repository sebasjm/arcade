#!/bin/bash

CMD_READING=78
CMD_DONE=79
function denomination() {
	case $1 in
		02) echo  10 ;;
		03) echo  20 ;;
		07) echo 500 ;;
		 *) echo   0 ;;
	esac	
}
LAST_COMMAND=0
CASH_IS_VALID=0

#serial device
# /dev/serial/by-id/usb-CCS_CCS_USB_to_UART-if00
#examples
# when cash is not recognized
# 78 14 79
# when cash is valid
# 78 79 02

DEVICE=$1
shift
stdbuf -oL -- \
	cat $DEVICE | \
	stdbuf -i0 -oL -- \
	xxd -g 0 -c 1 -ps | \
	while read code; do	
		if [ $LAST_COMMAND == $CMD_READING ] && [ $code == $CMD_DONE ]; then
			CASH_IS_VALID=1
		fi
		if [ $LAST_COMMAND == $CMD_DONE ]; then
			if [ $CASH_IS_VALID == 1 ]; then
				VALUE=$( denomination $code )
				echo inserted $VALUE
				ssh mendoza github/arcade/insert.sh $VALUE < /dev/null
			fi
			CASH_IS_VALID=0
		fi
		LAST_COMMAND=$code
	done

