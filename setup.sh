#!/bin/sh

if [ -n "$HOME" ]; then
    HADIR="$HOME/homeassistant/"
else
    HADIR=/home/homeautomation/homeassistant/
fi
cd $HADIR

if [ ! -d "$HADIR/env" ]; then
    python3 -m venv --system-site-packages env
fi

. env/bin/activate
#pip install wheel psycopg2-binary vext vext.gi

#be a bit less strict for some modules
export CFLAGS="-Wno-int-conversion"

if [ -n "$HASS_VERSION" ]; then
    echo "Installing explicit HASS version: $HASS_VERSION"
    pip install homeassistant==$HASS_VERSION
else
    echo "Installing latest HASS version"
    pip install homeassistant
fi
