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

[ -e "$MODE.01.jpg"] && mv -f "$MODE.01.jpg" "$MODE.02.jpg"

if [ "$MODE" = "livingroom" ]; then
    curl -sS "http://$LIVINGROOMCAM_IP:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$LIVINGROOMCAM_USER&pwd=$LIVINGROOMCAM_PASSWORD" -o "tmp.$MODE.jpg"
elif [ "$MODE" = "street" ]; then
    curl -sS "http://$STREETCAM_USER:$STREETCAM_PASSWORD@$STREETCAM_IP/Streaming/Channels/1/picture" -o "tmp.$MODE.jpg"
elif [ "$MODE" = "balcony" ]; then
    curl -sS "http://$BALCONYCAM_IP:88/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=$BALCONYCAM_USER&pwd=$BALCONYCAM_PASSWORD" -o "tmp.$MODE.jpg"
elif [ "$MODE" = "garden" ]; then
    curl -sS "http://$GARDENCAM_IP/snapshot.cgi?user=$GARDENCAM_USER&pwd=$GARDENCAM_PASSWORD" -o "tmp.$MODE.jpg"
else
    rm "$MODE.lock"
    echo "No such mode: $MODE" >&2
    exit 2
fi
[ -e "$MODE.00.jpg"] && mv -f "$MODE.00.jpg" "$MODE.01.jpg"
mv "tmp.$MODE.jpg" "$MODE.00.jpg"
rm "$MODE.lock"


exit 0
