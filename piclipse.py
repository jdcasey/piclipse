#!/usr/bin/env python

import RPi.GPIO as GPIO
from time import sleep
import picamera

RECORD_SW=22
CAPTURE_SW=27
RECORD_LED=17

GPIO.setmode(GPIO.BCM)
GPIO.setup(RECORD_SW, GPIO.IN)
GPIO.setup(CAPTURE_SW, GPIO.IN)
GPIO.setup(RECORD_LED, GPIO.OUT)

def capture_picture(path='/tmp/test.jpg'):
    with picamera.PiCamera() as cam:
        cam.resolution = (1024,768)
        cam.start_preview()

        sleep(2)
        cam.capture(path)

def capture_video(path='/tmp/test.h264'):
    with picamera.PiCamera() as cam:
        cam.start_recording(path)
        sleep(5)
        cam.stop_recording()

#capture_video()

recording=False
on=False
try:
    print "piclipse is ready"
    while True:
        if GPIO.input(RECORD_SW):
            print "Recording button press"
            recording=not recording
            on = recording
            GPIO.output(RECORD_LED, on)
            sleep(2)
        elif recording:
            on = not on
            GPIO.output(RECORD_LED, on)
        elif not recording and GPIO.input(CAPTURE_SW):
            print "Capture button press"
            GPIO.output(RECORD_LED, 1)
            sleep(5)
            GPIO.output(RECORD_LED, 0)
            on = False
        sleep(0.25)
finally:
    GPIO.cleanup()

