#!/bin/sh

export HAROOT="/home/homeautomation/homeassistant"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

#runs asynchronously, calls specified handlers
mqtt_receiver technofire

#runs asynchronously, calls specified sender
#         TOPIC
#         POLL-INTERVAL (seconds, 0=one-run)
#         SENDER
mqtt_transmitter "home/sensor/mhz19_co2" 60 mhz19

export GPIO_PIN_DHT22=4
export DHT22_MODE=c
mqtt_transmitter "home/sensor/temperature_living_room" 60 mhz19

export GPIO_PIN_DHT22=4
export DHT22_MODE=h
mqtt_transmitter "home/sensor/humidity_living_room" 360 mhz19


wait #wait for all children
