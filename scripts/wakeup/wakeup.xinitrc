#!/bin/bash
imagenr=$(( ( RANDOM % 6 )  + 1 ))
feh --bg-scale /home/homeautomation/homeassistant/media/sunrise$imagenr.jpg &
conky -c /home/homeautomation/homeassistant/scripts/wakeup/wakeup.conkyrc &
sleep 1; xset s off -dpms
play /home/homeautomation/homeassistant/media/morningbells_long.ogg &
exec dwm
