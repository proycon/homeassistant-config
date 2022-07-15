#!/bin/sh
export MPD_HOST="192.168.0.1"
TYPE=$1
VALUE=$2
FILTER=$3
echo "calling mpc search and play:"
echo "type: $TYPE, value: $VALUE, filter: $FILTER"
echo "type: $TYPE, value: $VALUE, filter: $FILTER" > /tmp/lastmpc
if [ -z "$FILTER" ] || [ "$FILTER" = "no" ]; then
    mpc search "$TYPE" "$VALUE" | mpc add || exit 2
elif [ -z "$4" ]; then
    mpc search "$TYPE" "$VALUE" | grep -e "$FILTER" | mpc add || exit 2
else
    mpc search "$TYPE" "$VALUE" | grep -e "$FILTER" -e "$4" | mpc add || exit 2
fi
mpc play
