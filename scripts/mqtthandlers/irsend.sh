#!/bin/sh

#take care to run everything asynchronously from this point onward!

havedep jq

handle_irsend() {
    case $TOPIC in
        "home/irsend/$HOSTNAME")
            DEVICE=$(echo "$PAYLOAD" | jq '.device')
            KEY=$(echo "$PAYLOAD" | jq '.key')
            "$HAROOT/scripts/media/irsend.sh" "$DEVICE" "$KEY" &
            return 0
            ;;
        *)
            #unhandled
            return 1
            ;;
    esac
}
