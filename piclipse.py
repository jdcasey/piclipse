#!/usr/bin/env python

import RPi.GPIO as GPIO
from time import sleep
import picamera

RECORD_SW=22
RECORD_LED=21

GPIO.setmode(GPIO.BCM)
GPIO.setup(RECORD_SW, GPIO.IN)
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

try:
    while True:
        if GPIO.input(RECORD_SW):
            print "Recording started"
            GPIO.output(RECORD_LED, 1)
        else:
            print "Recording released"
            GPIO.output(RECORD_LED, 0)
        sleep(0.1)
finally:
    GPIO.cleanup()

