#!/bin/sh

#take care to run everything asynchronously from this point onward!

havevar "GPIO_PIN_433SEND"

handle_433send() {
    case $TOPIC in
        "home/433send/set/$HOSTNAME/"*)
            PROTOCOL=$(echo "$TOPIC" | cut -d'/' -f5)
            GROUP=$(echo "$TOPIC" | cut -d'/' -f6)
            UNIT=$(echo "$TOPIC" | cut -d'/' -f7)
            STATE=$(echo "$PAYLOAD" | tr '[:upper:]' '[:lower:]')
            #perform the action (asynchronously)
            (
                if "$HAROOT/scripts/switch/433send.sh" "$GPIO_PIN_433SEND" "$PROTOCOL" "$GROUP" "$UNIT" "$STATE"; then
                    #and send confirmation back to the broker
                    STATE=$(echo "$STATE" | tr '[:lower:]' '[:upper:]')
                    mqttpub "home/433send/get/$PROTOCOL/$GROUP/$UNIT" "$STATE"
                else
                    error "433send failed: $HAROOT/scripts/switch/433send.sh $GPIO_PIN_433SEND $PROTOCOL $GROUP $UNIT $STATE"
                fi
            ) &
            return 0
            ;;
        *)
            #unhandled
            return 1
            ;;
    esac
}
