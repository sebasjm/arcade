#!/bin/bash

LOCK=/var/lock/arcade_watcher

exec 4>$LOCK
flock -xn 4
[ "$?" != "0" ] && echo another watch running, remove $LOCK if not && exit 1

function cleanup {
 trap - SIGHUP SIGINT SIGTERM SIGQUIT
 flock -u $LOCK
 exec 4<&-
 echo -n "Cleaning up... "
 kill $SERVER_PID
 kill -- -$$
 exit 1
}
trap cleanup SIGHUP SIGINT SIGTERM SIGQUIT

DIR="$(dirname -- "${BASH_SOURCE[0]:-$0}")"

set -e

#setup the server that will replay incoming connections
echo server up on 7772
socat TCP-LISTEN:7772,fork,reuseaddr,keepalive EXEC:"$DIR/reply.sh"
SERVER_PID=$!

