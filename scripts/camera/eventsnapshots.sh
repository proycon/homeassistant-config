#!/bin/bash
cd /tmp || exit 3
while [ -f eventsnapshots.lock ]; do
    sleep 1
done
touch eventsnapshots.lock
if [ $# -gt 1 ]; then
    CAMS=$@
    NUMCAMS=$#
else
    CAMS=("$1")
    NUMCAMS=${#CAMS[@]}
fi
mv -f event.11.jpg event.$((NUMCAMS+11)).jpg
mv -f event.10.jpg event.$((NUMCAMS+10)).jpg
mv -f event.9.jpg event.$((NUMCAMS+9)).jpg
mv -f event.8.jpg event.$((NUMCAMS+8)).jpg
mv -f event.7.jpg event.$((NUMCAMS+7)).jpg
mv -f event.6.jpg event.$((NUMCAMS+6)).jpg
mv -f event.5.jpg event.$((NUMCAMS+5)).jpg
mv -f event.4.jpg event.$((NUMCAMS+4)).jpg
mv -f event.3.jpg event.$((NUMCAMS+3)).jpg
mv -f event.2.jpg event.$((NUMCAMS+2)).jpg
mv -f event.1.jpg event.$((NUMCAMS+1)).jpg
NUM=0
EVENTDATE=$(date +%Y-%m-%d_%H:%M:%S)
for CAM in ${CAMS[@]}; do
    NUM=$((NUM+1))
    #convert -loop 0 -delay 500 $(find . -name "$DATE*$CAM*jpg" | sort | tail -n 6) $EVENTDATE.$CAM.gif
    if [ "$CAM" = "street" ]; then
        LENGTH=15
    elif [ "$CAM" = "garden" ]; then
        LENGTH=6
    else
        LENGTH=10
    fi
    IMAGES=$(find . -maxdepth 1 -name "$CAM.??.jpg" | sort | tail -n $LENGTH)
    echo "$EVENTDATE - $CAM - Event $NUM - Images: $IMAGES">&2
    IMAGEARRAY=($IMAGES)
    FIRSTIMAGE=${IMAGEARRAY[0]}
    convert $IMAGES -append -undercolor black -fill yellow -pointsize 16 -gravity north -annotate +0+0 "$FIRSTIMAGE - $EVENTDATE" event.$NUM.jpg &
done
rm eventsnapshots.lock
