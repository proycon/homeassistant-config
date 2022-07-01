#!/bin/bash
export MPD_HOST="192.168.0.1"
mpc clear
mpc playlist load "$1"
mpc play
