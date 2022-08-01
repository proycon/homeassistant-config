#!/bin/bash
#(POSIX shell doesn't suffice here)

# Receives notifications from MQTT

if [ -z "$HAROOT" ]; then
    echo "$HAROOT not set">&2
    exit 2
fi

. "$HAROOT/scripts/common/include.sh"

HANDLERS="$*"
#source all requested mqtt handlers
for handler in $HANDLERS; do
    handler=$(echo "$handler" | cut -d '@' -f 1) #@ is used to separate arguments
    # shellcheck disable=SC1090
    if [ -e "$HAROOT/scripts/mqtthandlers/$handler.sh" ]; then
        . "$HAROOT/scripts/mqtthandlers/$handler.sh"
    else
        die "Requested handler $handler not found!"
    fi
done

declare -a fields
declare -a payloadfields

while IFS= read -r line
do
	IFS="|" read -ra fields <<< $line; #-a is bash, not posix
	RECEIVETIME=${fields[0]} #time of reception
	TOPIC=${fields[1]}
	PAYLOAD="${fields[2]}"
    echo "MQTT IN> $TOPIC" >&2

    NOW=$(date +%s | tr -d '\n')

    #parse payload
    IFS=":" read -ra payloadfields <<< "$PAYLOAD";
    set -- "${payloadfields[@]}"
    MSGTIME="$1" #first argument may be a timestamp? check:
    case $MSGTIME in
         *[0-9]*)
            #assume to be a timestamp if numeric
            shift
            PAYLOAD=$(echo -e "$@" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') #trim
            echo "MQTT IN [@$MSGTIME]> $PAYLOAD" >&2
            TIMEDELTA=$(( NOW - MSGTIME ))
            ;;
        *)
            #no timestamp
            MSGTIME=$NOW
            TIMEDELTA=0
            echo "MQTT IN> $PAYLOAD" >&2
    esac

    for handler in $HANDLERS; do
        #A handler may contain contain arguments, separated by @
        case $handler in
            *@*)
                args=$(echo "$handler" | cut -d '@' -f '2-' | sed 's/@/ /g' ) #@ is used to separate arguments
                handler=$(echo "$handler" | cut -d '@' -f 1) #@ is used to separate arguments
                ;;
            *)
                args=
                ;;
        esac
        #shellcheck disable=SC2086
        handle_$handler $args && break   #break as soon as a handler completes successfully
    done

done < /dev/stdin
