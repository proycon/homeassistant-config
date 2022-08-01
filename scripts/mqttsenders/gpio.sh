#!/bin/sh

if [ -z "$HAROOT" ]; then
    echo "HAROOT not set">&2
    exit 2
fi
. "$HAROOT/scripts/common/include.sh"

havevar "$GPIO_PIN"
havedep "$HAROOT/programs/gpio_binary_sensor"

if [ -z "$1" ]; then
    error "handle_gpio: No gpio pin provided!"
    return 1
else
    GPIO_PIN=$1
fi

case "$GPIO_PULL" in
    down|DOWN)
        OPTS="-d"
        ;;
    up|UP)
        OPTS="-u"
        ;;
esac

[ -z "$PAYLOAD_ON" ] && PAYLOAD_ON=ON
[ -z "$PAYLOAD_OFF" ] && PAYLOAD_OFF=OFF

#shellcheck disable=SC2086
"$HAROOT/programs/gpio_binary_sensor" $OPTS -p $GPIO_PIN | while IFS= read -r line
do
    case "$line" in
        0)
            if [ -z "$GPIO_INVERT" ]; then
                echo $PAYLOAD_OFF
            else
                echo $PAYLOAD_ON
            fi
            ;;
        1)
            if [ -z "$GPIO_INVERT" ]; then
                echo $PAYLOAD_ON
            else
                echo $PAYLOAD_OFF
            fi
            ;;
    esac
done
