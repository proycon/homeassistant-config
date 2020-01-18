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

apt install aptitude tmux git gcc make zsh kodi kodi-audioencoder-flac kodi-audioencoder-lame kodi-audioencoder-vorbis wiringpi python3-virtualenv vim || exit 1

if grep "MYSETUP: LIRC" /boot/config.txt; then
    echo "lirc already set up"
else
    echo "#MYSETUP: LIRC" >> /boot/config.txt
    if [ $PI -eq 1 ]; then
        echo "dtoverlay=gpio-ir-tx,gpio_pin=17" >> /boot/config.txt
    elif [ $PI -eq 2 ]; then
        echo "dtoverlay=gpio-ir,gpio_pin=24" >> /boot/config.txt
        echo "dtoverlay=gpio-ir-tx,gpio_pin=4" >> /boot/config.txt
    fi

    echo "REBOOT FIRST NOW AND THEN RUN THIS SCRIPT AGAIN"
    exit 0
fi

apt install lirc lirc-compat-remotes || exit 1

if [ ! -d /home/homeautomation ]; then
    useradd -s /bin/bash -m -d /home/homeautomation -G pi,adm,dialout,cdrom,sudo,audio,video,plugdev,users,input,netdev,spi,i2c,gpio homeautomation || exit 1
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
sudo -u homeautomation ./setup.sh || exit 6

echo "please reboot first now"


