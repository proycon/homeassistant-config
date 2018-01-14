Home Assistant Configuration
===============================

This repository contains my elaborate home automation configuration, using [Home Assistant](https://home-assistant.io).

Introduction
------------

Prior to Home Assistant, I ran my own custom-built home automation software. This got too time consuming to maintain and
expand so in the summer of 2017 I migrated everything to Home Assistant.

I have a main server and various Raspberry Pis distributed through the house (for wiring reasons). One of the challenges
was getting them to communicate properly with Home Assistant. I decided on simply running a Home Assistant instance on each
(EventStream solutions did not work properly for me), have the master instance control as much as possible, and the
slaves as bare as possible, with communication proceeding over MQTT.

Goals
--------

* Automate and integrate as much as possible:
    * Lights
    * TV
    * Audio
    * Cameras
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
    * Apache webserver
    * *Audio streaming:* [Mopidy](https://www.mopidy.com/) (MPD) + Modidy-spotify + Iris + Icecast
    * *Messaging:* XMPP (Prosody)
* **Slave**: Raspberry Pi 1 (Raspbian) ([GPIO wiring schematic](https://github.com/proycon/homeassistant-config/blob/master/docs/pi1.svg))
    * GPIO: 433.92Mhz Transmitter for lights
    * GPIO: Door/doorbell sensors (wired, reed contacts)
    * GPIO: IR LED for remote control of TV/audio
* **Slave**: Raspberry Pi 2 (Raspbian) ([GPIO wiring schematic](https://github.com/proycon/homeassistant-config/blob/master/docs/pi2.svg)r)]
    * GPIO: 433.92Mhz Transmitter for lights
    * GPIO: Door/window sensors (wired, reed contacts)
    * GPIO: Neopixels LED for ambilight in living room
    * GPIO: IR LED for remote control of TV/audio
    * GPIO: IR Receiver
* **Slave**: Raspberry Pi 3 (Raspbian)
    * GPIO: [DH-22 temperature/humidity sensor](https://www.adafruit.com/product/385)
    * GPIO: Neopixels LED fireplace ([video](https://www.youtube.com/watch?v=i18eXQIXzXg))
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
        * 1x ALECTO WS-4500 Weather Station (mouted outside for wind, rain, temperature)
* **Z-Wave**
    * Aeotec Z-Stick
    * 3x [Fibaro Motion/light/temperature sensor](https://www.fibaro.com/en/products/motion-sensor/)
    * 1x Neo Coolcam Door/window sensor
    * 2x Nodon Softremote buttons for scene selection/quick remote functionality
    * 1x Philiotech Temperature/Humidity Sensor for bathroom

Interface
------------

Some screenshots of the interface:

![Main screenshot](https://raw.githubusercontent.com/proycon/homeassistant-config/master/docs/screenshot_main.png)

![Media controls](https://raw.githubusercontent.com/proycon/homeassistant-config/master/docs/screenshot_tv.png)

![Camera](https://raw.githubusercontent.com/proycon/homeassistant-config/master/docs/screenshot_cam.png)





