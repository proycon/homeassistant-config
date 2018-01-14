Home Assistant Configuration
===============================

This repository contains my elaborate home automation configuration, using [Home Assistant](https://home-assistant.io).

Overview
------------

Prior to Home Assistant, I ran my own custom-built home automation software. This got too time consuming to maintain and
expand so I in the summer of 2017 I migrated everything to Home Assistant.

I have a main server and various Raspberry Pis distributed through the house (for wiring reasons). One of the challenges
was getting them communicate properly with Home Assistant. I decided on simply running a Home Assistant instance on each
(EventStream solutions did not work properly for me), have the master instance control as much as possible, and the
slaves as bare as possible, with communication proceeding over MQTT.

I have the following devices:

* **Master:** Main server (Ubuntu Linux)
    * Quad core
    * 16GB RAM
    * Aeotec Z-Stick
    * Apache webserver
* **Slave**: Raspberry Pi 1 (Raspbian) ([GPIO wiring schematic](https://github.com/proycon/homeassistant-config/blob/master/docs/pi1.svg)]
    * GPIO: 433.92Mhz Transmitter for lights
    * GPIO: Door/doorbell sensors (wired, reed contacts)
    * GPIO: IR LED for remote control of TV/audio
* **Slave**: Raspberry Pi 2 (Raspbian) ([GPIO wiring schematic](https://github.com/proycon/homeassistant-config/blob/master/docs/pi2.svg)]
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
    * Living room
    * Street
    * Garden
* **Webcams**
    * Front door
    * Hallway
* **433 Mhz**
    * Klik-aan-klik-Uit Adapters or older ELRO adapters for all lights
    * [RFLink Transceiver](http://www.rflink.nl/), based on Arduino Mega, connected to Pi2
    * ALECTO WS-4500 Weather Station
* **Z-Wave**
    * Aeotec Z-Stick
    * 3x [Fibaro Motion/light/temperature sensor](https://www.fibaro.com/en/products/motion-sensor/)
    * 1x Neo Coolcam Door/window sensor
    * 2x Nodon Softremote buttons for scene selection/quick remote functionality
    * 1x Philiotech Temperature/Humidity Sensor for bathroom









