#!/bin/bash
pkill -f technofire.py > /dev/null 2>/dev/null
/home/homeautomation/homeassistant/scripts/technofire/technofire.py "$1" "$2"
