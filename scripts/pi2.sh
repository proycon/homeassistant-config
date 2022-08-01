#!/bin/sh

export HAROOT="/home/homeautomation/homeassistant"

. "$HAROOT/scripts/common/include.sh"

settrap #kill all children when dying

export GPIO_PIN_433SEND=4
export SNAPCAST_SOUNDCARD=17
export ONEWIRE_DEVICE_ID=28-0000059319c4

export GPIO25_TOPIC="home/binary_sensor/backdoor"
export GPIO25_INVERT=1
export GPIO25_PULL=down
export GPIO17_TOPIC="home/binary_sensor/bedroomwindow_right"
export GPIO17_INVERT=1
export GPIO17_PULL=down
export GPIO22_TOPIC="home/binary_sensor/bedroomwindow_left"
export GPIO22_INVERT=1
export GPIO22_PULL=down

#runs asynchronously, calls specified handlers
mqtt_receiver 433send sound musicplayer tts kodi technofire irsend

#runs asynchronously, calls specified sender
#         TOPIC
#         POLL-INTERVAL (seconds, 0=one-run)
#         SENDER
mqtt_transmitter "home/sensor/bedroom_temperature" 60 onewire 

export GPIO_PIN=25
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/backdoor" 0 gpio

export GPIO_PIN=17
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/bedroomwindow_right" 0 gpio


export GPIO_PIN=22
export GPIO_INVERT=1
export GPIO_PULL=down
mqtt_transmitter "home/binary_sensor/bedroomwindow_left" 0 gpio

wait #wait for all children
