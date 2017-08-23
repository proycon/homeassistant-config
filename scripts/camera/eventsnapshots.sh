#!/bin/bash
cd /home/homeautomation/homeassistant/snapshots/
CAM=$1
while [ -f eventsnapshots.lock ]; do
    sleep 1
done
touch eventsnapshots.lock
DATE=`date +%Y-%m-%d_`
EVENTDATE=`date +%Y-%m-%d_%H:%M:%S`
#convert -loop 0 -delay 500 $(find . -name "$DATE*$CAM*jpg" | sort | tail -n 6) $EVENTDATE.$CAM.gif
mv -f event.5.jpg event.6.jpg
mv -f event.4.jpg event.5.jpg
mv -f event.3.jpg event.4.jpg
mv -f event.2.jpg event.3.jpg
mv -f event.1.jpg event.2.jpg
IMAGES=$(find . -name "$DATE*$CAM*jpg" | sort | tail -n 6)
IMAGEARRAY=($IMAGES)
FIRSTIMAGE=${IMAGEARRAY[0]}
convert $IMAGES -append -fill yellow -pointsize 16 -gravity north -annotate +0+0 "$FIRSTIMAGE - $EVENTDATE" event.1.jpg
rm eventsnapshots.lock
