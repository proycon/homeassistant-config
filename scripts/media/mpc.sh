#!/bin/bash
if [ -z "$3" ] || [[ "$3" == "no" ]]; then
    mpc search "$1" "$2" | mpc add
elif [ -z "$4" ]; then
    mpc search "$1" "$2" | grep -e "$3" | mpc add
else
    mpc search "$1" "$2" | grep -e "$3" -e "$4" | mpc add
fi
mpc play
