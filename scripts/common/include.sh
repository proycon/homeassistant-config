#!/bin/sh

EXIT=0

die() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] FATAL ERROR: $*">&2
    exit 2
}

error() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] ERROR: $*">&2
}

info() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] INFO: $*">&2
}

debug() {
    NOW=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$NOW] DEBUG: $*">&2
}


havedep() {
    command -v "$1" >/dev/null 2>/dev/null || die "missing dependency $1"
}

havevar() {
    [ -n "${1}" ] || die "missing variable: $1"
}


if [ -z "$HAROOT" ]; then
    die "$HAROOT not set"
fi

if [ -e "$HAROOT/.mqtt_secrets" ]; then
    . "$HAROOT/.mqtt_secrets"
elif [ -e "$HOME/.mqtt_secrets" ]; then
    . "$HOME/.mqtt_secrets"
elif [ -e "/etc/mqtt_secrets" ]; then
    . "/etc/mqtt_secrets"
fi

mqttcheck() {
    [ -n "$MQTT_USER" ] || die "No MQTT user defined"
    [ -n "$MQTT_PASSWORD" ] || die "No MQTT password defined"
    [ -n "$MQTT_HOST" ] || MQTT_HOST="anaproy.nl"
    [ -n "$MQTT_PORT" ] || MQTT_PORT=8333
    if [ -e /etc/ssl/certs/ca-cert-ISRG_Root_X1.pem ]; then
        CACERT="/etc/ssl/certs/ca-cert-ISRG_Root_X1.pem"
    elif [ -e /etc/ssl/certs/ISRG_Root_X1.pem ]; then
        CACERT="/etc/ssl/certs/ISRG_Root_X1.pem"
    elif [ -e /etc/ssl/certs/ca-cert-ISRG_Root_X1.pem ]; then
        CACERT="/etc/ssl/certs/ca-cert-ISRG_Root_X1.pem"
    elif [ -e /etc/ssl/certs/DST_Root_CA_X3.pem ]; then
        CACERT="/etc/ssl/certs/DST_Root_CA_X3.pem"
    elif [ -e /etc/ssl/certs/ca-cert-DST_Root_CA_X3.pem ]; then
        CACERT="/etc/ssl/certs/ca-cert-DST_Root_CA_X3.pem"
    else
        die "mqttcheck: CA Certificate not found"
    fi
}

mqttpub() {
    #Publish a single message
    mqttcheck

    if [ -n "$TOPIC" ]; then
        #topic already set in environment
        true #noop, nothing to do
    elif [ -n "$1" ]; then
        TOPIC="$1"
        shift
    else
        error "No topic provided"
        return 2
    fi

    if [ -n "$1" ]; then
        PAYLOAD="$1"
    else
        PAYLOAD="ON"
    fi

    info "mqttpub: $TOPIC - $PAYLOAD"
    if ! mosquitto_pub -I "$HOSTNAME" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t "$TOPIC" -m "$PAYLOAD" --qos 1 $MQTT_OPTIONS; then
        error "mqttpub failed"
        return 1
    fi
}

mqtt_receiver() {
    #Subscribes to MQTT and registers one or more mqtthandler scripts

    mqttcheck
    #run asynchronously
    (
        EXIT=0
        trap 'EXIT=1' HUP
        while [ $EXIT -eq 0 ]; do
            info "mqttsub: $*"
            #shellcheck disable=SC2068,SC2086
            if ! mosquitto_sub -c -q 1 -i "$HOSTNAME" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t '#' -F "@H:@M:@S|%t|%p" $MQTT_OPTIONS | "$HAROOT/scripts/common/mqtthandler.sh" $@; then
                #small delay before reconnecting
                error "mqttsub failed ($*), reconnecting after 10s grace period..."
                sleep 10
            fi
            #note: mqtthandler is a separate script rather than inline here because it requires bash rather than posix shell
        done
    ) &
}


mqtt_transmitter() {
    #Registers one or more mqttsender scripts and publishes their output to MQTT
    mqttcheck


    if [ -n "$1" ]; then
        TOPIC="$1"
        shift
    else
        error "No topic provided"
        return 2
    fi

    if [ -n "$1" ]; then
        case $1 in
            (*[!0-9]*|'') die "expected polling interval integer, got $1 instead";;
            *) ;;
        esac
        INTERVAL="$1"
        shift
    else
        error "No polling interval provided"
        return 2
    fi

    [ -n "$1" ] || die "no sender specified"
    SENDER=$1
    [ ! -e "$HAROOT/scripts/mqttsenders/$SENDER.sh" ] && die "Script mqttsenders/$SENDER.sh not found"
    shift
    (
        EXIT=0
        trap 'EXIT=1' HUP
        while [ $EXIT -eq 0 ]; do
            info "mqtt_transmitter: $SENDER $*"
            #shellcheck disable=SC2068,SC2086
            if [ $INTERVAL -gt 0 ]; then
                #sender runs at specified interval
                PAYLOAD=$("$HAROOT/scripts/mqttsenders/$SENDER.sh" $@)
                #shellcheck disable=SC2181 #--> usage of $?
                if [ $? -ne 0 ]; then
                    #small delay before reconnecting
                    error "mqtt sender script failed ($SENDER.sh $*), reconnecting after 10s grace period..."
                    sleep 10
                elif ! mosquitto_pub -I "$HOSTNAME" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t "$TOPIC" -m "$PAYLOAD" -l --qos 1 $MQTT_OPTIONS; then
                    #small delay before reconnecting
                    error "mqtt publish for sender failed ($SENDER.sh $*), reconnecting after 10s grace period..."
                    sleep 10
                else
                    #normal behaviour
                    sleep $INTERVAL
                fi
            else
                #sender runs continuously (invoked once), each outputted line is transmitted over mqtt as payload
                "$HAROOT/scripts/mqttsenders/$SENDER.sh" $@ | while IFS= read -r PAYLOAD; do
                    if ! mosquitto_pub -I "$HOSTNAME" -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$MQTT_USER" -P "$MQTT_PASSWORD" --cafile "$CACERT" -t "$TOPIC" -m "$PAYLOAD" -l --qos 1 $MQTT_OPTIONS; then
                        error "mqttpub from sender failed ($SENDER.sh $*)..."
                        return 1
                    fi
                done
                #shellcheck disable=SC2181 #--> usage of $?
                error "mqtt sender failed ($SENDER.sh $*), reconnecting after 10s grace period..."
                sleep 10
            fi
        done
    ) &
}


if [ -z "$USER" ]; then
    USER="$(whoami)"
fi
if [ -z "$HOSTNAME" ]; then
    HOSTNAME="$(hostname)"
fi

if command -v aplay > /dev/null; then
    export PLAY="aplay"
else
    export PLAY="mpv --no-video --really-quiet"
fi

[ -z "$TMPDIR" ] && export TMPDIR=/tmp
