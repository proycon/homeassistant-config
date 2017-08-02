#!/bin/sh
if [ $# -ne 5 ]; then
    echo "Requiring five arguments!" >&2
    exit 2
fi
while [ -f /tmp/43392.lock ]; do
    sleep 1
done
touch /tmp/43392.lock
echo "Calling 433send $1 $2 $3 $4 $5" >&2
/home/homeautomation/homeassistant/scripts/switch/433mhzforpi/433send $1 $2 $3 $4 $5
rm /tmp/43392.lock
