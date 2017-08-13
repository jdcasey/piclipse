#!/usr/bin/env python

import RPi.GPIO as GPIO
from time import sleep
import picamera

RECORD_SW=22
CAPTURE_SW=27
RECORD_LED=17
READY_LED=24

GPIO.setmode(GPIO.BCM)
GPIO.setup(RECORD_SW, GPIO.IN)
GPIO.setup(CAPTURE_SW, GPIO.IN)
GPIO.setup(RECORD_LED, GPIO.OUT)
GPIO.setup(READY_LED, GPIO.OUT)

def capture_picture(path='/tmp/test.jpg'):
    # with picamera.PiCamera() as cam:
    cam.start_preview()

    sleep(2)
    cam.capture(path)

def start_recording(path='/tmp/test.h264'):
    # with picamera.PiCamera() as cam:
        cam.start_recording(path)

def stop_recording():
        cam.stop_recording()

#capture_video()

cam = picamera.PiCamera()
cam.resolution = (1024,768)

recording=False
on=False
try:
    print "piclipse is ready"
    GPIO.output(READY_LED, 1)
    while True:
        if GPIO.input(RECORD_SW):
            recording=not recording

            on = recording
            GPIO.output(RECORD_LED, on)
            sleep(2)
            if recording is True:
                print "Video recording started"
                start_recording()
                GPIO.output(READY_LED, 0)
            else:
                print "Video recording stopped"
                stop_recording()
                GPIO.output(READY_LED, 1)

        elif recording:
            on = not on
            GPIO.output(RECORD_LED, on)

        elif not recording and GPIO.input(CAPTURE_SW):
            print "Capturing still image"
            GPIO.output(RECORD_LED, 1)
            GPIO.output(READY_LED, 0)
            capture_picture()
            GPIO.output(RECORD_LED, 0)
            GPIO.output(READY_LED, 1)
            on = False

        sleep(0.25)
finally:
    if cam:
        cam.close()

    GPIO.cleanup()
