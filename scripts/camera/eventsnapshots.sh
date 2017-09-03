#!/bin/bash
cd /home/homeautomation/homeassistant/snapshots/
while [ -f eventsnapshots.lock ]; do
    sleep 1
done
touch eventsnapshots.lock
if [ $# -gt 1 ]; then
    CAMS=$@
    NUMCAMS=$#
else
    CAMS=($1)
    NUMCAMS=${#CAMS[@]}
fi
mv -f event.5.jpg event.$((NUMCAMS+5)).jpg
mv -f event.4.jpg event.$((NUMCAMS+4)).jpg
mv -f event.3.jpg event.$((NUMCAMS+3)).jpg
mv -f event.2.jpg event.$((NUMCAMS+2)).jpg
mv -f event.1.jpg event.$((NUMCAMS+1)).jpg
NUM=0
DATE=`date +%Y-%m-%d_`
EVENTDATE=`date +%Y-%m-%d_%H:%M:%S`
for CAM in ${CAMS[@]}; do
    NUM=$((NUM+1))
    #convert -loop 0 -delay 500 $(find . -name "$DATE*$CAM*jpg" | sort | tail -n 6) $EVENTDATE.$CAM.gif
    IMAGES=$(find . -maxdepth 1 -name "$DATE*$CAM*jpg" | sort | tail -n 6)
    IMAGEARRAY=($IMAGES)
    FIRSTIMAGE=${IMAGEARRAY[0]}
    convert $IMAGES -append -undercolor black -fill yellow -pointsize 16 -gravity north -annotate +0+0 "$FIRSTIMAGE - $EVENTDATE" event.$NUM.jpg &
done
rm eventsnapshots.lock
