#!/bin/sh

handle_kodi() {
    case $TOPIC in
        "home/kodi/set/$HOSTNAME"|"home/kodi/$HOSTNAME")
            STATE=$(echo "$PAYLOAD" | tr '[:lower:]' '[:upper:]')
            if [ "$STATE" = "ON" ]; then
                pidof kodi || kodi &
            elif [ "$STATE" = "OFF" ]; then
                killall kodi &
            else
                #no state provided, determine and return state
                if pidof -q kodi; then
                    STATE="ON"
                else
                    STATE="OFF"
                fi
            fi
            mqttpub "home/kodi/get/$HOSTNAME" "$STATE" &
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
