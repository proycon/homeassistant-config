#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havevar "$GPIO_PIN_DHT22"
havevar "$DHT22_MODE" #c for temperature in celsius, h for humidity
havedep "$HAROOT/programs/dht22"

"$HAROOT/programs/dht22" $DHT22_MODE $GPIO_PIN_DHT22
