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
LAST_WAS_DONE=0

#serial device
#/dev/serial/by-id/usb-CCS_CCS_USB_to_UART-if00
DEVICE=$1
shift

stdbuf -oL --\
	cat $DEVICE | \
	stdbuf -i0 -oL -- \
	xxd -g 0 -c 1 -ps | \
	while read code; do 
		if [ $LAST_WAS_DONE == 1 ]; then
			VALUE=$( denomination $code )
			echo inserted $VALUE
			ssh mendoza github/arcade/insert.sh $VALUE
		fi
		LAST_WAS_DONE=$(( $code == $CMD_DONE ? 1 : 0 ))
	done
