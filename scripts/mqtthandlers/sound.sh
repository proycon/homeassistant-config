#!/bin/sh

handle_sound() {
    case $TOPIC in
        "home/sound/$HOSTNAME")
            FILENAME="$HAROOT/media/$PAYLOAD"
            if [ -f "$FILENAME" ]; then
                $PLAY "$FILENAME" &
            else
                error "Unable to play $FILENAME, file not found"
            fi
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
