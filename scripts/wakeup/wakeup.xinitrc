#!/bin/bash
imagenr=$(( ( RANDOM % 6 )  + 1 ))
feh --bg-scale /home/homeautomation/homeassistant/media/sunrise$imagenr.jpg &
conky -c /home/homeautomation/homeassistant/scripts/wakeup/wakeup.conkyrc &
sleep 1; xset s off -dpms
<<<<<<< HEAD
play /home/homeautomation/homeassistant/media/morningbells_long.ogg &
exec twm
=======
exec dwm
>>>>>>> a47dbdd0e1d84edaba38d43d76d42f313a7c90dd

