#!/bin/sh

. /home/homeautomation/homeassistant/private/secrets.sh
cd /tmp || exit 4

DATE=$(date +%Y-%m-%d_%H:%M:%S)

MODE=$1
if [ -z "$MODE" ]; then
    echo "No mode set!" >&2
    exit 2
fi

if [ -f "$MODE.lock" ]; then
    exit 1
else
    touch "$MODE.lock"
fi

FLIP=0
if [ -n "$2" ]; then
    if [ "$2" = "ON" ] || [ "$2" = "on" ] || [ "$2" = "true" ]; then
        FLIP=1
    fi
fi

if [ "$MODE" = "livingroom" ]; then
    curl -sS "http://$LIVINGROOMCAM_IP:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$LIVINGROOMCAM_USER&pwd=$LIVINGROOMCAM_PASSWORD" -o "tmp.$MODE.jpg"
    if [ $FLIP -eq 1 ]; then
        convert -flip -flop "tmp.$MODE.jpg" "_$MODE.jpg"
    else
        mv "tmp.$MODE.jpg" "_$MODE.jpg"
    fi
elif [ "$MODE" = "street" ]; then
    curl -sS "http://$STREETCAM_USER:$STREETCAM_PASSWORD@$STREETCAM_IP/Streaming/Channels/1/picture" -o "tmp.$MODE.jpg"
    mv "tmp.$MODE.jpg" "_$MODE.jpg"
elif [ "$MODE" = "balcony" ]; then
    curl -sS "http://$BALCONYCAM_IP:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$BALCONYCAM_USER&pwd=$BALCONYCAM_PASSWORD" -o "$DATE.$MODE.jpg"
elif [ "$MODE" = "garden" ]; then
    curl -sS "http://$GARDENCAM_IP/snapshot.cgi?user=$GARDENCAM_USER&pwd=$GARDENCAM_PASSWORD" -o "$DATE.$MODE.jpg"
else
    rm "$MODE.lock"
    echo "No such mode: $MODE" >&2
    exit 2
fi

rm "$MODE.lock"


exit 0
