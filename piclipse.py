#!/usr/bin/env python

import time
import picamera

def capture_picture(path='/tmp/test.jpg'):
    with picamera.PiCamera() as cam:
        cam.resolution = (1024,768)
        cam.start_preview()

        time.sleep(2)
        cam.capture(path)

def capture_video(path='/tmp/test.h264'):
    with picamera.PiCamera() as camera:
        camera.start_recording(path)
        time.sleep(5)
        camera.stop_recording()

capture_video()

