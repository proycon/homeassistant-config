#!/bin/bash

HOST=$(hostname)
HADIR=/home/homeautomation/homeassistant/
if [ $HOST == "roma" ]; then
    HOST="master"
fi

if [ ! -d "$HADIR/env" ]; then
    echo "Virtualenv not setup yet for $HOST" >&2
    exit 2
fi

. $HADIR/env/bin/activate

if [ ! -d "$HADIR/$HOST" ]; then
    echo "No way to start for host $HOST" >&2
    exit 2
fi

hass -c "$HADIR/$HOST"

