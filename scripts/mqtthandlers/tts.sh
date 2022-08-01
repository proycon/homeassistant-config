#!/bin/sh

#take care to run everything asynchronously from this point onward!

handle_tts() {
    case $TOPIC in
        "home/say/$HOSTNAME")
            "$HAROOT/scripts/voice/picotts.sh" "$PAYLOAD" &
            return 0
            ;;
        *)
            #unhandled
            return 1
            ;;
    esac
}
