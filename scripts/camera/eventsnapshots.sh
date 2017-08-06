#!/bin/bash
cd /home/homeautomation/homeassistant/snapshots/
CAM=$1
if [ ! -z "$2" ]; then
    sleep $2
fi
if [ -f eventsnapshots.$CAM.lock ]; then
    exit 0
fi
touch eventsnapshots.$CAM.lock
DATE=`date +%Y-%m-%d_`
EVENTDATE=`date +%Y-%m-%d_%H:%M:%S`
if [ -f event.$CAM.latest.gif ]; then
    mv event.$CAM.latest.gif event.$CAM.previous.gif
fi
convert -loop 0 -delay 500 $(find . -name "$DATE*$CAM*jpg" | sort | tail -n 6) $EVENTDATE.$CAM.gif
ln -sf $EVENTDATE.$CAM.gif event.$CAM.latest.gif
rm eventsnapshots.$CAM.lock
