import snowboydecoder
import sys
import signal
import os

interrupted = False


def signal_handler(signal, frame):
    global interrupted
    interrupted = True


def interrupt_callback():
    global interrupted
    return interrupted

def onhotword():
    snowboydecoder.play_audio_file("/home/homeautomation/homeassistant/media/computerbeep_5.wav")
    os.system("rec /tmp/recording.wav rate 16k trim 0 5 silence -l 1 0.1 3% 1 1.2 3%")
    snowboydecoder.play_audio_file("/home/homeautomation/homeassistant/media/computerbeep_65.wav")

if len(sys.argv) == 1:
    print("Error: need to specify model name")
    print("Usage: python demo.py your.model")
    sys.exit(-1)

model = sys.argv[1]

# capture SIGINT signal, e.g., Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

detector = snowboydecoder.HotwordDetector(model, sensitivity=0.45)
print('Listening... Press Ctrl+C to exit')

# main loop
detector.start(detected_callback=onhotword,  #snowboydecoder.play_audio_file,
               interrupt_check=interrupt_callback,
               sleep_time=0.03)

detector.terminate()

