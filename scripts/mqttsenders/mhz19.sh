#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havedep "$HAROOT/programs/mhz19/mhz19"

"$HAROOT/programs/mhz19/mhz19"
