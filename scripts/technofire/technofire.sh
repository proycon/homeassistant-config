#!/bin/bash
pkill -f technofire.py
/home/homeautomation/homeassistant/scripts/technofire/technofire.py "$1" "$2"
