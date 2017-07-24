from __future__ import print_function, unicode_literals, division, absolute_import

import time
import random
import sys
import os

from neopixel import *

colorstate = {}

# LED strip configuration:
LED_COUNT      = 30      # Number of LED pixels.
LED_PIN        = 18      # GPIO pin connected to the pixels (must support PWM!).
LED_FREQ_HZ    = 800000  # LED signal frequency in hertz (usually 800khz)
LED_DMA        = 5       # DMA channel to use for generating signal (try 5)
LED_BRIGHTNESS = 255     # Set to 0 for darkest and 255 for brightest
LED_INVERT     = False   # True to invert the signal (when using NPN transistor level shift)

def off(strip):
    for i in range(strip.numPixels()):
        strip.setPixelColor(i, Color(0,0,0))
    strip.show()

def singlecolor(strip, color):
    for i in range(strip.numPixels()):
        strip.setPixelColor(i, color)
    strip.show()

def sparkle():
    return Color(random.randint(190,255), random.randint(1,102), 0)

def initfire(strip):
    global colorstate
    for i in range(strip.numPixels()):
        colorstate[i] = sparkle()
        strip.setPixelColor(i, colorstate[i])
    strip.show()

def fire(strip, offchance=0.1, holdchance=0.4, wait_ms=20):
    global colorstate
    for pixel in range(strip.numPixels()):
        p = random.random()
        if p < offchance:
            colorstate[pixel] = Color(0,0,0)
        elif p >= offchance + holdchance:
            colorstate[pixel] = sparkle()
        strip.setPixelColor(pixel, colorstate[pixel])
        strip.show()
    time.sleep(wait_ms/1000.0)


# Define functions which animate LEDs in various ways.
def colorWipe(strip, color, wait_ms=50):
    """Wipe color across display a pixel at a time."""
    for i in range(strip.numPixels()):
        strip.setPixelColor(i, color)
        strip.show()
        time.sleep(wait_ms/1000.0)

def theaterChase(strip, color, wait_ms=50, iterations=10):
    """Movie theater light style chaser animation."""
    for j in range(iterations):
        for q in range(4):
            for i in range(0, strip.numPixels(), 3):
                strip.setPixelColor(i+q, color)
            strip.show()
            time.sleep(wait_ms/1000.0)
            for i in range(0, strip.numPixels(), 3):
                strip.setPixelColor(i+q, 0)

def wheel(pos):
    """Generate rainbow colors across 0-255 positions."""
    if pos < 85:
        return Color(pos * 3, 255 - pos * 3, 0)
    elif pos < 170:
        pos -= 85
        return Color(255 - pos * 3, 0, pos * 3)
    else:
        pos -= 170
        return Color(0, pos * 3, 255 - pos * 3)

def rainbow(strip, wait_ms=20, iterations=1):
    """Draw rainbow that fades across all pixels at once."""
    for j in range(256*iterations):
        for i in range(strip.numPixels()):
            strip.setPixelColor(i, wheel((i+j) & 255))
        strip.show()
        time.sleep(wait_ms/1000.0)

def rainbowCycle(strip, wait_ms=20, iterations=5):
    """Draw rainbow that uniformly distributes itself across all pixels."""
    for j in range(256*iterations):
        for i in range(strip.numPixels()):
            strip.setPixelColor(i, wheel(((i * 256 / strip.numPixels()) + j) & 255))
        strip.show()
        time.sleep(wait_ms/1000.0)

def theaterChaseRainbow(strip, wait_ms=50):
    """Rainbow movie theater light style chaser animation."""
    for j in range(256):
        for q in range(3):
            for i in range(0, strip.numPixels(), 3):
                strip.setPixelColor(i+q, wheel((i+j) % 255))
            strip.show()
            time.sleep(wait_ms/1000.0)
            for i in range(0, strip.numPixels(), 3):
                strip.setPixelColor(i+q, 0)

def sirene(strip):
    singlecolor(strip,Color(255,0,0))
    time.sleep(0.250)
    off(strip)
    time.sleep(0.15)
    singlecolor(strip,Color(0,0,255))
    time.sleep(0.250)
    off(strip)
    time.sleep(0.15)


# Main program logic follows:
if __name__ == '__main__':
    # Create NeoPixel object with appropriate configuration.
    strip = Adafruit_NeoPixel(LED_COUNT, LED_PIN, LED_FREQ_HZ, LED_DMA, LED_INVERT, LED_BRIGHTNESS)
    # Intialize the library (must be called once before other functions).
    strip.begin()

    try:
        scene = sys.argv[1]
    except IndexError:
        scene = "fire"

    if scene == "fire":
        initfire(strip)
        while True:
            fire(strip)
    elif scene == "redwipe":
        while True:
            colorWipe(strip, Color(255, 0, 0))  # Red wipe
    elif scene == "bluewipe":
        while True:
            colorWipe(strip, Color(0, 255, 0))  # Blue wipe
    elif scene == "greenwipe":
        while True:
            colorWipe(strip, Color(0, 0, 255))  # Blue wipe
    elif scene == "whitechase":
        while True:
            theaterChase(strip, Color(127, 127, 127))  # White theater chase
    elif scene == "redchase":
        while True:
            theaterChase(strip, Color(127,   0,   0))  # Red theater chase
    elif scene == "bluechase":
        while True:
            theaterChase(strip, Color(0,   0,   127))  # Red theater chase
    elif scene == "rainbow":
        while True:
            rainbow(strip)
    elif scene == "rainbowcycle":
        while True:
            rainbowCycle(strip)
    elif scene == "rainbowchase":
        while True:
            theaterChaseRainbow(strip)
    elif scene == "sirene":
        while True:
            sirene(strip)
    elif scene == "off":
        off(strip)
    else:
        print("No such scene")
