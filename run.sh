#!/bin/sh

die() {
    echo "$*" >&2
    exit 2
}

if [ -n "$HOME" ]; then
    HADIR="$HOME/homeassistant/"
else
    HADIR=/home/homeautomation/homeassistant/
fi
cd "$HADIR" || die "Directory does not exist"
export PULSE_SERVER="10.0.2.2"

if [ ! -d "$HADIR/env" ]; then
    echo "Virtualenv not setup yet for $HOST" >&2
    ./setup.sh || die "Setup failed"
fi

if [ -d "$HADIR/snapshots" ]; then
    rm "$HADIR"/snapshots/*.lock
fi

. "$HADIR/env/bin/activate"

hass -c "$HADIR"
