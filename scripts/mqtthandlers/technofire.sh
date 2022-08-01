#!/bin/sh

#take care to run everything asynchronously from this point onward!

havedep jq

run_technofire() {
    if [ "$SCENE" = "off" ]; then
        STATE="off"
    else
        STATE="on"
    fi
    mqttpub "home/technofire/$HOSTNAME/state" "$STATE" & #feedback
    #sudo must be set up to allow passwordless access for technofire.sh
    sudo "$HAROOT/scripts/technofire/technofire.sh" --brightness "$BRIGHTNESS" --iter $ITERATIONS "$SCENE" &
}

handle_technofire() {
    case $TOPIC in
        "home/technofire/set/$HOSTNAME/"*)
            SCENE=$(echo "$TOPIC" | cut -d'/' -f5 | tr " " "_" | tr "[:upper:]" "[:lower:]")
            BRIGHTNESS=$(echo "$TOPIC" | cut -d'/' -f6)
            ITERATIONS=0
            run_technofire
            return 0
            ;;
        "home/technofire/jsonset/$HOSTNAME")
            SCENE=$(echo "$PAYLOAD" | jq '.scene' | tr " " "_" | tr "[:upper:]" "[:lower:]")
            BRIGHTNESS=$(echo "$PAYLOAD" | jq '.brightness')
            ITERATIONS=$(echo "$PAYLOAD" | jq '.iterations')
            run_technofire
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
