#!/bin/bash

HOST=$(hostname)
HADIR=/home/homeautomation/homeassistant/
cd $HADIR
if [ $HOST == "roma" ] || [ $HOST == "homeautomation" ]; then
    HOST="master"
fi
if [ $HOST == "homeautomation" ]; then
    export PULSE_SERVER="10.252.116.1"
fi

if [ ! -d "$HADIR/env" ]; then
    echo "Virtualenv not setup yet for $HOST" >&2
    ./setup.py
fi
if [ -d "$HADIR/snapshots" ]; then
    rm $HADIR/snapshots/*.lock
fi

. $HADIR/env/bin/activate

if [ ! -d "$HADIR/$HOST" ]; then
    echo "No way to start for host $HOST" >&2
    exit 2
fi

hass -c "$HADIR/$HOST"

