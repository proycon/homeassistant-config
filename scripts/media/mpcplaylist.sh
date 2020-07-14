#!/bin/bash
export MPD_HOST="proycon@mediaserver.anaproy.lxd"
mpc clear
mpc playlist load "$1"
mpc play
