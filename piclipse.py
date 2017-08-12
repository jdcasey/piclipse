#!/usr/bin/env python

import time
import picamera

with picamera.PiCamera() as cam:
    cam.resolution = (1024,768)
    cam.start_preview()

    time.sleep(2)
    cam.capture("/tmp/test.jpg")


