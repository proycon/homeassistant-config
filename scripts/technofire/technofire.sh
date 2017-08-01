#!/bin/bash
sudo pkill -f technofire.py
sudo /home/homeautomation/homeassistant/scripts/technofire/technofire.py "$1" "$2"
