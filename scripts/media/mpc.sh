#!/bin/bash
export MPD_HOST="proycon@mediaserver.anaproy.lxd"
TYPE=$1
VALUE=$2
FILTER=$3
echo "calling mpc search and play:">&2
echo "type: $TYPE">&2
echo "value: $VALUE">&2
echo "filter: $FILTER">&2
if [ -z "$FILTER" ] || [[ "$FILTER" == "no" ]]; then
    mpc search "$TYPE" "$VALUE" | mpc add
elif [ -z "$4" ]; then
    mpc search "$TYPE" "$VALUE" | grep -e "$FILTER" | mpc add
else
    mpc search "$TYPE" "$VALUE" | grep -e "$FILTER" -e "$4" | mpc add
fi
mpc play
