#!/bin/bash

U=$(whoami)
if [[ "$U" != "root" ]]; then
    echo "script should be run as root"
    exit 2
fi

if [ -z "$1" ]; then
    echo "add pi number as parameter"
    exit 2
fi
PI=$1

apt update || exit 2
apt upgrade || exit 2
systemctl enable ssh || exit 2

systemctl set-default multi-user.target || exit 2 #no graphical UI by default
ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service

apt install aptitude tmux git gcc make lirc lirc-compat-remotes zsh kodi kodi-audioencoder-flat kodi-audioencoder-lame kodi-audioencoder-vorbis wiringpi python3-virtualenv || exit 1


if [ ! -d /home/homeautomation ]; then
    useradd -s /bin/zsh -m -d /home/homeautomation -G pi,adm,dialout,cdrom,sudo,audio,video,plugdev,users,input,netdev,spi,i2c,gpio homeautomation || exit 1
    if [ $PI -eq 1 ]; then
        echo "dtoverlay=lirc-rpi,gpio_out_pin=17" >> /boot/config.txt
    elif [ $PI -eq 2 ]; then
        echo "dtoverlay=lirc-rpi,gpio_out_pin=4,gpio_in_pin=24" >> /boot/config.txt
    fi
fi

if [ ! -d /home/homeautomation/homeassistant ]; then
    cd /home/homeautomation
    chmod o+x /home/homeautomation
    sudo -u homeautomation git clone --recursive https://github.com/proycon/homeassistant-config homeassistant || exit 1
    cd /home/homeautomation/homeassistant
    cd scripts/switch/433mhzforpi
    sudo -u homeautomation make || exit 3
    make install || exit 4
    cd /home/homeautomation/homeassistant
    ln -s /home/homeautomation/homeassistant/config/my.lircd.conf /etc/lirc/lircd.conf.d/my.lircd.conf || exit 5
fi

systemctl enable lircd

cd /home/homeautomation/homeassistant
sudo -u homeassistant ./setup.sh || exit 6

echo "please reboot first now"


