#!/bin/bash
pkill -f technofire.py > /dev/null 2>/dev/null
echo $1
echo $2
echo $3
/home/homeautomation/homeassistant/scripts/technofire/technofire.py "$1" "$2" "$3"
