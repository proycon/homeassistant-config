#!/bin/bash
imagenr=$(( ( RANDOM % 6 )  + 1 ))
feh --bg-scale ~/homeassistant/media/sunrise$imagenr.jpg &
conky -c ~/homeassistant/scripts/wakeup/wakeup.conkyrc &
sleep 1; xset s off -dpms
exec twm

