#!/bin/sh

#Onewire temperature sensor DS18B20

. "$HAROOT/scripts/common/include.sh"

havevar ONEWIRE_DEVICE_ID
ONEWIRE_FILE="/sys/devices/w1_bus_master1/$ONEWIRE_DEVICE_ID/temperature"

if [ -e "$ONEWIRE_FILE" ]; then
    TEMP="$(cat "$ONEWIRE_FILE")" #will report an integer in celsius * 1000
    [ -n "$TEMP" ] && echo "$TEMP / 1000" | bc -l
else
    die "Onewire file not found: $ONEWIRE_FILE"
fi
