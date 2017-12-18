#!/usr/bin/env python3

import sys
from pprint import pprint
import speech_recognition as sr
import time

rec = sr.Recognizer()
#with sr.AudioFile(AUDIO_FILE) as source:
#    audio = r.record(source) # read the entire audio file
mic = sr.Microphone()

with mic as source:
    rec.adjust_for_ambient_noise(source)

WIT_AI_KEY = sys.argv[1]  # Wit.ai keys are 32-character uppercase alphanumeric strings

def callback(recognizer, audio):
    try:
        print("Wit.ai recognition results:")
        pprint(rec.recognize_wit(audio, key=WIT_AI_KEY, show_all=True))  # pretty-print the recognition result
    except sr.UnknownValueError:
        print("Wit.ai could not understand audio")
    except sr.RequestError as e:
        print("Could not request results from Wit.ai service; {0}".format(e))

stop_listening = rec.listen_in_background(mic, callback, phrase_time_limit=0.6)
time.sleep(5)

