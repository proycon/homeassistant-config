Home Assistant Configuration
===============================

This repository contains my elaborate home automation configuration, using [Home Assistant](https://home-assistant.io).

Introduction
------------

Prior to Home Assistant, I ran my own custom-built home automation software. This got too time consuming to maintain and
expand so in the summer of 2017 I migrated everything to Home Assistant. As time went by some of the choices Home Assistant made no longer aligned with mine and I found it too bloated and too GUI-drived, so I started migrating parts back to my new custom-built solution called [lighthome](https://git.sr.ht/~proycon/lighthome). These two now work in tandem and complement another.

I have a main server and various Raspberry Pis distributed through the house (for wiring reasons). The main server runs home assistant and is the nexus of my home automation (it also runs a small lighthome instance), the raspberry pis and various other clients (even my phone) run lighthome.

Goals
--------

* Automate and integrate as much as possible:
    * Lights
    * TV
    * Audio
    * Cameras
    * Heating and air conditioning
    * Lots of environment sensors for automations
* **Open-source** and **no** third-party cloud solutions, I like to own and safeguard my data!
* Security/Alarm system

Devices
-----------

I have the following devices:

* **Master:** Main server (Ubuntu Linux)
    * Quad core
    * 16GB RAM
    * Aeotec Z-Stick
    * *Webserver*: Nginx
    * *MQTT Broker:* Mosquitto
    * *Audio streaming:* [Mopidy](https://www.mopidy.com/) (MPD) + Modidy-spotify + Iris + Icecast
    * *Messaging:* XMPP (Prosody)
* **Slave**: Raspberry Pi 1 (Raspbian) ([GPIO wiring schematic](https://github.com/proycon/homeassistant-config/blob/master/docs/pi1.svg))
    * GPIO: 433.92Mhz Transmitter for lights (see also https://github.com/proycon/433mhzforrpi/)
    * GPIO: Door/doorbell sensors (wired, reed contacts)
    * GPIO: IR LED for remote control of TV/audio
* **Slave**: Raspberry Pi 2 (Raspbian) ([GPIO wiring schematic](https://github.com/proycon/homeassistant-config/blob/master/docs/pi2.svg))
    * GPIO: 433.92Mhz Transmitter for lights
    * GPIO: Door/window sensors (wired, reed contacts)
    * GPIO: Neopixels LED (WS2812B) for ambilight in living room
    * GPIO: IR LED for remote control of TV/audio
    * GPIO: IR Receiver
* **Slave**: Raspberry Pi 3 (Raspbian)
    * GPIO: [DH-22 temperature/humidity sensor](https://www.adafruit.com/product/385)
    * GPIO: Neopixels LED (WS2912B) fireplace ([video](https://www.youtube.com/watch?v=i18eXQIXzXg), [sources](https://github.com/proycon/homeassistant-config/tree/master/scripts/technofire))
    * GPIO: [PIR sensor](https://www.adafruit.com/product/189)
* **IP Cams**
    * Living room (D-Link 5222-L)
    * Street (Foscam)
    * Garden (Foscam)
* **Webcams**
    * Front door
    * Hallway
* **433 Mhz**
    * Many Klik-aan-klik-Uit Adapters or older ELRO adapters for all lights
    * 1x [RFLink Transceiver](http://www.rflink.nl/), based on Arduino Mega, connected to Pi2
        * 1x ALECTO WS-4500 Weather Station (mounted outside for wind, rain, temperature)
* **Z-Wave**
    * Aeotec Z-Stick
    * 3x [Fibaro Motion/light/temperature sensor](https://www.fibaro.com/en/products/motion-sensor/)
    * 3x Neo Coolcam Door/window sensor
    * 2x Nodon Softremote buttons for scene selection/quick remote functionality
    * 1x Philiotech Temperature/Humidity Sensor for bathroom
    * 3x Remotec ZRC-90 remote
 * **Other**
    * *Slimme Meter* for power consumption, connected to main server
    * Plugwise Anna thermostat
    * Devantech ETH-008 relais switch for upstairs lights
    * Daitek air conditioning with wifi module
    * Solar panels
    * Speakers throughout the house for text-to-speech notifications
    * Wake up timer through bedroom TV
    * Xiaomi Roborock S2 (rooted, access over ssh with root@$IP, using my normal personal ssh keypair)

Interface
------------

Some screenshots of the interface, featuring [home assistant tiles](https://github.com/c727/home-assistant-tiles/):

![Main screenshot](https://raw.githubusercontent.com/proycon/homeassistant-config/master/docs/screenshot_main.png)

![Media controls](https://raw.githubusercontent.com/proycon/homeassistant-config/master/docs/screenshot_tv.png)

![Camera](https://raw.githubusercontent.com/proycon/homeassistant-config/master/docs/screenshot_cam.png)





