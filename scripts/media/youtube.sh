#!/bin/sh

# Downloads a video from youtube (or elsewhere)


MODE="$1"
URL="$2"
PI="$3"

cd /home/homeautomation
. scripts/secrets.sh

if [ ! -z "$MQTT_HOST" ]; then
    echo "No MQTT host defined">&2
    exit 2
fi

if [ ! -z "$MQTT_USER" ]; then
    echo "No MQTT user defined">&2
    exit 2
fi

if [ ! -z "$MQTT_PASSWORD" ]; then
    echo "No MQTT password defined">&2
    exit 2
fi

case $MODE in
    play)
        rm /nettmp/videoqueue/.seqnr
        rm /nettmp/videoqueue/*
        SEQNR=1
        ;;
    add)
        if [ ! -f /nettmp/videoqueue/.seqnr ]; then
            SEQNR=1
        else
            SEQNR=$(cat /nettmp/videoqueue/.seqnr)
            SEQNR=$((SEQNR + 1))
        fi
        if [ $SEQNR -gt 999 ]; then
            SEQNR=1
        fi
        ;;
    clear)
        rm /nettmp/videoqueue/.seqnr
        rm /nettmp/videoqueue/*
        exit 0
        ;;
    *)
        echo "invalid mode: $1">&2
        exit 1
esac

case $URL in
    http://*|https://*)
        URL=$URL
        ;;
    *)
        URL="https://www.youtube.com/watch?v=$URL"
        ;;
esac

echo $SEQNR > /nettmp/videoqueue/.seqnr
SEQNR=$(printf "%03d" $SEQNR)


echo "Downloading $url as #$SEQNR" >&2
mosquitto_pub -I youtube -h "$MQTT_HOST" -p 8883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile /etc/ssl/certs/ISRG_Root_X1.pem -t "home/say/pi$PI" -m "downloading, please wait" --qos 1
yt-dlp -f "bestvideo[height<=1080]+bestaudio" -P temp:/nettmp/videotmp -P home:/nettmp/videoqueue -o "$SEQNR-%(title)s.%(ext)s" "$URL"
RET=$?
cd /nettmp/videoqueue
if ls -1 $SEQNR-*; then
    if [ "$SEQNR" = "001" ]; then
        mosquitto_pub -I youtube -h "$MQTT_HOST" -p 8883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile /etc/ssl/certs/ISRG_Root_X1.pem -t "home/command/kodi$PI/play" -m "directory:/nettmp/videoqueue/" --qos 1
    else
        mosquitto_pub -I youtube -h "$MQTT_HOST" -p 8883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile /etc/ssl/certs/ISRG_Root_X1.pem -t "home/say/pi$PI" -m "ready" --qos 1
    fi
else
    mosquitto_pub -I youtube -h "$MQTT_HOST" -p 8883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile /etc/ssl/certs/ISRG_Root_X1.pem -t "home/say/pi$PI" -m "download failed" --qos 1
fi
exit $RET
