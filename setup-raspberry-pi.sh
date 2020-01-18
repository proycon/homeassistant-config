#!/bin/bash

U=$(whoami)
if [[ "$U" != "root" ]]; then
    echo "script should be run as root"
    exit 2
fi

apt update || exit 2
apt upgrade || exit 2
systemctl enable ssh || exit 2

apt install aptitude tmux git gcc make lirc lirc-compat-remotes zsh kodi kodi-audioencoder-flat kodi-audioencoder-lame kodi-audioencoder-vorbis wiringpi python3-virtualenv

if [ ! -d /home/homeautomation ]; then
    useradd -s /bin/zsh -m -d /home/homeautomation -G pi,adm,dialout,cdrom,sudo,audio,video,plugdev,users,input,netdev,spi,i2c,gpio homeautomation
fi
if [ ! -d /home/homeautomation/homeassistant ]; then
    cd /home/homeautomation
    sudo -u homeautomation git clone --recursive https://github.com/proycon/homeassistant-config homeassistant
    cd /home/homeautomation/homeassistant
    cd scripts/switch/433mhzforpi
    sudo -u homeautomation make || exit 3
    make install
fi

cd /home/homeautomation/homeassistant
sudo -u homeassistant ./setup.sh


