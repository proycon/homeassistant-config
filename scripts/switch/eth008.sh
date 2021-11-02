#!/usr/bin/env sh
source /home/homeautomation/homeassistant/scripts/secrets.sh
if [ -n "$1" ]; then
    curl --user $ETH008_USER:$ETH008_PASSWORD "http://$ETH008_IP/io.cgi?relay=$1"
else
    curl --user $ETH008_USER:$ETH008_PASSWORD "http://$ETH008_IP/io.cgi"
fi
