#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "$HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep pico2wave

TMPFILE="$(mktemp -q /$TMPDIR/XXXXXXX.wav)"
pico2wave -l en_GB -w "$TMPFILE" "$PAYLOAD" && $PLAY "$TMPFILE" 
RET=$?
rm "$TMPFILE"
exit $RET
