#!/bin/sh

handle_musicplayer() {
    case $TOPIC in
        "home/musicplayer/set/$HOSTNAME"|"home/musicplayer/$HOSTNAME")
            STATE=$(echo "$PAYLOAD" | tr '[:lower:]' '[:upper:]')
            if [ "$STATE" = "ON" ]; then
                killall snapclient
                snapclient -s "${SNAPCAST_SOUNDCARD:-default}" -h anaproy.nl >/dev/null 2>/dev/null &
            elif [ "$STATE" = "OFF" ]; then
                killall snapclient &
            else
                #no state provided, determine and return state
                if pidof -q snapclient; then
                    STATE="ON"
                else
                    STATE="OFF"
                fi
            fi
            mqttpub "home/musicplayer/get/$HOSTNAME" "$STATE" &
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
