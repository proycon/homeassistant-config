# Architecture

* Simple light-weight shell scripts
* MQTT as a central broker between everything

* `common/include.sh` - Defines common functions, including:
    * ``mqtt_receiver *[handlers]*`` - Subscribes to MQTT and registers one or more handler scripts, takes care of reconnect logic in case of failures, parallelisation, and runs asynchronously
    * ``mqtt_transmitter *[senders]*`` - Takes input and publishes it on MQTT, takes care of reconnect logic in case of failures, parallelisation, and runs asynchronously
    * ``mqttpub *[topic]* *[payload]*``- Publish a single MQTT message

* **handler scripts** (``mqtthandlers/*``) - Receives MQTT stream on standard input and should invoke scripts that perform the action by calling an action script. 
    * These scripts are sourced and everything inside but be run asynchronously!'
    * The script doesn't have to deal with MQTT itself, except if it wants to publish feedback (using ``mqttpub``)
* **sender scripts** (``mqttsenders/*``) - Monitors some device/sensor (preferably via an independent action script or program) and then translates its output for MQTT (standard output) 
    * These scripts are run normally, either over and over at a specified interval or as a one-shot script that runs indefinitely by itself.
    * Standard output serves as payload for MQTT (the script doesn't have to deal with MQTT itself)
* **actions scripts and programs** (``*``, ``../programs/``) - Perform any action, completely MQTT unaware, can also be invoked independently from command line for low-level testing



