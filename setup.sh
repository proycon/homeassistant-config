#!/bin/sh

if [ -n "$HOME" ]; then
    HADIR="$HOME/homeassistant/"
else
    HADIR=/home/homeautomation/homeassistant/
fi
cd $HADIR

if [ ! -d "$HADIR/env" ]; then
    python3 -m venv env
fi

. env/bin/activate

if [ -n "$HASS_VERSION" ]; then
    pip install homeassistant==$HASS_VERSION
else
    pip install -U homeassistant
fi
