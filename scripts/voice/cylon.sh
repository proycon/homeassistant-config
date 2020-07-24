#!/bin/bash
#this uses the vocoder from https://github.com/borsboom/vocoder
espeak -s 100 -a 200 -w mod.wav "$@"
vocoder -b 64 mod.wav carrier.wav cylon.wav
