#!/usr/bin/env python3

from __future__ import print_function, unicode_literals, division, absolute_import

# NeoPixel library strandtest example
import time
import random
import sys
import os
import argparse

HOST = os.uname()[1]

from neopixel import *

colorstate = {}

parser = argparse.ArgumentParser(description="", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
#snippet hints --> addargb,addargs,addargi,addargf, addargpos, addarglist
parser.add_argument('--leds',type=int, help="LED count", action='store', default=30)
parser.add_argument('--pin',type=int, help="GPIO pin", action='store', default=18)
parser.add_argument('--brightness','-b',type=int, help="Brightness (0..255)", action='store', default=255)
parser.add_argument('--iter','-i',type=int, help="Number of iterations (0=infinite)", action='store', default=0)
parser.add_argument('scene', nargs=1, help="Scene")
args = parser.parse_args() #parsed arguments can be accessed as attributes

# LED strip configuration:
LED_COUNT      = args.leds      # Number of LED pixels.
LED_PIN        = args.pin       # GPIO pin connected to the pixels (must support PWM!).
LED_FREQ_HZ    = 800000  # LED signal frequency in hertz (usually 800khz)
LED_DMA        = 5       # DMA channel to use for generating signal (try 5)
LED_BRIGHTNESS = args.brightness     # Set to 0 for darkest and 255 for brightest
LED_INVERT     = False   # True to invert the signal (when using NPN transistor level shift)


def loop(iterations):
    if iterations == 0:
        while True:
            yield 0
    else:
        for i in range(0,iterations):
            yield i

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

def knightrider(strip, wait_ms=50, iterations=10):
    color=Color(255,0,0)
    length=4
    for i in range(0, strip.numPixels()- length):
        for j in range(0,length):
            strip.setPixelColor(i+j, color)
        strip.show()
        time.sleep(wait_ms/1000.0)
        strip.setPixelColor(i, 0)
    size = strip.numPixels()
    for i in range(size-length, 0,-1):
        for j in range(0,length):
            strip.setPixelColor(i+j, color)
        strip.show()
        time.sleep(wait_ms/1000.0)
        strip.setPixelColor(i+length, 0)

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
            strip.setPixelColor(i, wheel(((i * 256 // strip.numPixels()) + j) & 255))
        strip.show()
        time.sleep(wait_ms/1000.0)

def colorCycle(strip, wait_ms=20, iterations=5):
    for j in range(256*iterations):
        for i in range(strip.numPixels()):
            strip.setPixelColor(i, wheel(((256 // strip.numPixels()) + j) & 255))
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

def colorFade(strip, color, maxbrightness=255, wait_ms=250, wait_fade_ms=0):
    for i in range(strip.numPixels()):
        strip.setPixelColor(i, color)
    for i in range(maxbrightness+1):
        strip.setBrightness(i)
        strip.show()
        if wait_fade_ms > 0:
            time.sleep(wait_fade_ms/1000.0)
    time.sleep(wait_ms/1000.0)
    for i in range(maxbrightness,0,-1):
        strip.setBrightness(i)
        strip.show()
        if wait_fade_ms > 0:
            time.sleep(wait_fade_ms/1000.0)



# Main program logic follows:
if __name__ == '__main__':
    # Create NeoPixel object with appropriate configuration.
    strip = Adafruit_NeoPixel(LED_COUNT, LED_PIN, LED_FREQ_HZ, LED_DMA, LED_INVERT, LED_BRIGHTNESS, 0 , ws.WS2811_STRIP_GRB)
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
    elif scene == "red_wipe":
        for _ in loop(args.iterations):
            colorWipe(strip, Color(255, 0, 0))  # Red wipe
    elif scene == "blue_wipe":
        for _ in loop(args.iterations):
            colorWipe(strip, Color(0, 255, 0))  # Blue wipe
    elif scene == "green_wipe":
        for _ in loop(args.iterations):
            colorWipe(strip, Color(0, 0, 255))  # Blue wipe
    elif scene == "white_chase":
        for _ in loop(args.iterations):
            theaterChase(strip, Color(127, 127, 127))  # White theater chase
    elif scene == "red_chase":
        for _ in loop(args.iterations):
            theaterChase(strip, Color(127,   0,   0))  # Red theater chase
    elif scene == "blue_chase":
        for _ in loop(args.iterations):
            theaterChase(strip, Color(0,   0,   127))  # Red theater chase
    elif scene == "knightrider":
        for _ in loop(args.iterations):
            knightrider(strip)
    elif scene == "rainbow":
        for _ in loop(args.iterations):
            rainbow(strip)
    elif scene == "rainbow_slow":
        for _ in loop(args.iterations):
            rainbow(strip,250)
    elif scene == "rainbow_cycle":
        for _ in loop(args.iterations):
            rainbowCycle(strip)
    elif scene == "colorcycle_fast":
        for _ in loop(args.iterations):
            colorCycle(strip)
    elif scene == "colorcycle":
        for _ in loop(args.iterations):
            colorCycle(strip,500)
    elif scene == "colorcycle_slow":
        for _ in loop(args.iterations):
            colorCycle(strip,2000)
    elif scene == "rainbow_chase":
        for _ in loop(args.iterations):
           theaterChaseRainbow(strip)
    elif scene == "white":
        singlecolor(strip, Color(255,255,255))
    elif scene == "red":
        singlecolor(strip, Color(255,0,0))
    elif scene == "green":
        singlecolor(strip, Color(0,255,0))
    elif scene == "blue":
        singlecolor(strip, Color(0,0,255))
    elif scene == "yellow":
        singlecolor(strip, Color(255,255,0))
    elif scene == "purple":
        singlecolor(strip, Color(255,0,255))
    elif scene == "cyan":
        singlecolor(strip, Color(0,255,255))
    elif scene == "whitish":
        singlecolor(strip, Color(244,243,169))
    elif scene == "lamp":
        singlecolor(strip, Color(196,181,51))
    elif scene == "redalert":
        for _ in loop(args.iterations):
            colorFade(strip, Color(255,0,0))
    elif scene == "red_notice":
        for _ in loop(args.iterations):
            colorFade(strip, Color(255,0,0),maxbrightness=100,wait_fade_ms=25)
    elif scene == "yellowalert":
        for _ in loop(args.iterations):
            colorFade(strip, Color(255,255,0))
    elif scene == "yellow_notice":
        for _ in loop(args.iterations):
            colorFade(strip, Color(255,255,0),maxbrightness=100,wait_fade_ms=25)
    elif scene == "greenalert":
        for _ in loop(args.iterations):
            colorFade(strip, Color(0,255,0))
    elif scene == "green_notice":
        for _ in loop(args.iterations):
            colorFade(strip, Color(0,255,0),maxbrightness=100,wait_fade_ms=25)
    elif scene == "bluealert":
        for _ in loop(args.iterations):
            colorFade(strip, Color(0,0,255))
    elif scene == "blue_notice":
        for _ in loop(args.iterations):
            colorFade(strip, Color(0,0,255),maxbrightness=100,wait_fade_ms=25)
    elif scene == "sirene":
        for _ in loop(args.iterations):
            sirene(strip)
    elif scene == "off":
        off(strip)
    else:
        print("No such scene")
