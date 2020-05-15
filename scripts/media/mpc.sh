#!/bin/bash
export MPD_HOST="proycon@mediaserver.anaproy.lxd"
TYPE=$1
VALUE=$2
FILTER=$3
echo "calling mpc search and play:"
echo "type: $TYPE, value: $VALUE, filter: $FILTER"
echo "type: $TYPE, value: $VALUE, filter: $FILTER" > /tmp/lastmpc
if [ -z "$FILTER" ] || [[ "$FILTER" == "no" ]]; then
    mpc search "$TYPE" "$VALUE" | mpc add
elif [ -z "$4" ]; then
    mpc search "$TYPE" "$VALUE" | grep -e "$FILTER" | mpc add
else
    mpc search "$TYPE" "$VALUE" | grep -e "$FILTER" -e "$4" | mpc add
fi
mpc play
