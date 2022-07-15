#!/bin/sh

# Downloads a video from youtube (or elsewhere)


MODE="$1"
URL="$2"
PI="$3"

say() {
    mosquitto_pub -I youtube -h "$MQTT_HOST" -p 8883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile /etc/ssl/certs/ISRG_Root_X1.pem -t "home/say/pi$PI" -m "$1" --qos 1
}

cd /home/homeautomation || exit 3
. homeassistant/scripts/secrets.sh

if [ -z "$MQTT_HOST" ]; then
    echo "No MQTT host defined">&2
    exit 2
fi

if [ -z "$MQTT_USER" ]; then
    echo "No MQTT user defined">&2
    exit 2
fi

if [ -z "$MQTT_PASSWORD" ]; then
    echo "No MQTT password defined">&2
    exit 2
fi

if [ ! -d /nettmp/videoqueue ]; then
    say "unable to download, disk not mounted"
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
        URL="$URL"
        ;;
    *)
        URL="https://www.youtube.com/watch?v=$URL"
        ;;
esac

echo $SEQNR > /nettmp/videoqueue/.seqnr
SEQNR=$(printf "%03d" $SEQNR)


echo "Downloading $URL as #$SEQNR" >&2
say "downloading, please wait"
yt-dlp -f "bestvideo[height<=1080]+bestaudio" -P temp:/nettmp/videotmp -P home:/nettmp/videoqueue -o "$SEQNR-%(title)s.%(ext)s" "$URL"
RET=$?
cd /nettmp/videoqueue || exit 3
if ls -1 $SEQNR-*; then
    if [ "$MODE" = "play" ]; then
        #raw query, but we let home assistant mediate via MQTT
        #curl -X POST --user $KODI_USER:$KODI_PASSWORD -H "content-type:application/json" http://192.168.0.12:8080/jsonrpc -d '{"jsonrpc":"2.0","id":1,"method":"Player.Open","params":{"item": {"directory":"/home/homeautomation/Server/videoqueue/" } } }'
        mosquitto_pub -I youtube -h "$MQTT_HOST" -p 8883 -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile /etc/ssl/certs/ISRG_Root_X1.pem -t "home/command/kodi$PI/playdir" -m "/home/homeautomation/Server/videoqueue/" --qos 1
    else
        say "ready"
    fi
else
    say "download failed"
fi
exit $RET
