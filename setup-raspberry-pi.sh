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

echo "pi$PI" > /etc/hostname

apt update || exit 2
apt upgrade || exit 2
systemctl enable ssh || exit 2

systemctl set-default multi-user.target || exit 2 #no graphical UI by default

apt install aptitude tmux git gcc make zsh kodi python3-virtualenv virtualenv vim cec-utils libcec-dev python3-cec scons snapclient || exit 1
apt install kodi-audioencoder-flac

echo "homeautomation    ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/030_homeautomation



if grep "MYSETUP" /boot/config.txt; then
    echo "already set up"
else
    echo "#MYSETUP" >> /boot/config.txt
    if [ $PI -eq 1 ] || [ $PI -eq 2 ]; then
        #set default device to USB audio and disable internal sound
        sed -i s/defaults.ctl.card 0/defaults.ctl.card 1/ /usr/share/alsa/alsa.conf
        sed -i s/defaults.pcm.card 0/defaults.pcm.card 1/ /usr/share/alsa/alsa.conf
    fi
    if [ $PI -eq 1 ]; then
        echo "dtoverlay=gpio-ir-tx,gpio_pin=17" >> /boot/config.txt
        echo " snd_bcm2835.enable_headphones=1 snd_bcm2835.enable_hdmi=1 snd_bcm2835.enable_compat_alsa=0" >> /boot/cmdline.txt
    elif [ $PI -eq 2 ]; then
        sed -i 's/audio=on/audio=off/' /boot/config.txt
        echo "dtoverlay=gpio-ir,gpio_pin=24" >> /boot/config.txt
        echo "dtoverlay=gpio-ir-tx,gpio_pin=4" >> /boot/config.txt
        #OLD: echo "dtoverlay=lirc-rpi,gpio_out_pin=4,gpio_in_pin=24" >> /boot/config.txt
        echo "dtoverlay=w1-gpio,gpiopin=11" >> /boot/config.txt
    fi

    echo "REBOOT FIRST NOW AND THEN RUN THIS SCRIPT AGAIN"
    exit 0
fi



apt install lirc lirc-compat-remotes || exit 1

if [ ! -d /home/homeautomation ]; then
    useradd -s /bin/bash -m -d /home/homeautomation -G pi,adm,dialout,cdrom,sudo,audio,video,plugdev,users,input,netdev,spi,i2c,gpio homeautomation || exit 1
    sudo -u homeautomation mkdir /home/homeautomation/bin
    sudo -u homeautomation mkdir /home/homeautomation/Server
    echo "sshfs -o reconnect,workaround=rename,idmap=user,follow_symlinks,allow_other,ro proycon@mediaserver.anaproy.lxd:/mediashare /home/homeautomation/Server" > /home/homeautomation/bin/mountssh
    chmod a+x /home/homeautomation/bin/mountssh
fi

if [ ! -d /home/homeautomation/WiringPi ]; then
    cd /home/homeautomation
    sudo -u homeautomation git clone https://github.com/WiringPi/WiringPi
    cd /home/homeautomation/WiringPi
    ./build || exit 3
    ldconfig
fi

if [ ! -d /home/homeautomation/rpi_ws281x ]; then
    cd /home/homeautomation/rpi_ws281x
    sudo -u homeautomation git clone https://github.com/jgarff/rpi_ws281x || exit 3
    sudo -u homeautomation scons || exit 3
    cd /home/homeautomation/rpi_ws281x/python
    python setup.py install  || exit 3
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
    cp -f homeassistant/config/homeautomation@homeautomation.service /etc/systemd/system/
    systemctl daemon-reload
fi

systemctl enable lircd

cd /home/homeautomation/homeassistant
sudo -u homeautomation ./setup.sh || exit 6

systemctl enable homeautomation@homeautomation
systemctl disable snapclient  #do not run on boot

echo "Note: copy SSH keys manually from another raspberry pi!"
echo "Done, please reboot first now"
