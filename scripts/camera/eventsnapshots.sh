#!/bin/bash
cd /home/homeautomation/homeassistant/snapshots/
if [ ! -z "$2" ]; then
    sleep $2
fi
if [ -f /tmp/eventsnapshots.$CAM.lock ]; then
    exit 0
fi
touch /tmp/eventsnapshots.$CAM.lock
CAM=$1
DATE=`date +%Y-%m-%d_`
EVENTDATE=`date +%Y-%m-%d_%H:%M:%S`
SNAPSHOTS=$(find /home/homeautomation/homeassistant/snapshots/ -name "$DATE*$CAM*.jpg" | tail -n 10)
if [ -f event.$CAM.latest.gif ]; then
    mv event.$CAM.latest.gif event.$CAM.previous.gif
fi
if [ ! -z "$SNAPSHOTS" ]; then
    cat $SNAPSHOTS | xargs -I '{}' convert -loop 0 -delay 500 {} $EVENTDATE.$CAM.gif
    ln -sf $EVENTDATE.$CAM.gif event.$CAM.latest.gif
fi
rm /tmp/eventsnapshots.$CAM.lock
