#!/usr/bin/env python

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import RPi.GPIO as GPIO
from time import sleep
import picamera
import sys
import os
import datetime as dt
from subprocess import call

STILL_RESOLUTION = (2592,1944)
VID_RESOLUTION = (1920,1080)
MB=1024*1024

# This is the first argument to the service, and establishes where output should be written.
OUT_DIR=sys.argv[1]
if not os.path.isdir(OUT_DIR):
    print "Cannot find output directory: %s\n\nUsage: %s <output-dir>" % (OUT_DIR, sys.argv[0])
    exit(1)

# Sub-directories for pictures and videos, to keep things cleaner
CAP_DIR = os.path.join(OUT_DIR, "Pictures")
VID_DIR = os.path.join(OUT_DIR, "Video")

# Ensure the capture directories exist.
for d in (CAP_DIR, VID_DIR):
    if not os.path.isdir(d):
        os.makedirs(d)

# BCM GPIO numbers for the pins we'll be interfacing with from the RPi.
RECORD_SW=22
CAPTURE_SW=27
RECORD_LED=17
READY_LED=24

# Setup GPIO by establishing pin numbering scheme and types of usage for each pin.
GPIO.setmode(GPIO.BCM)
GPIO.setup(RECORD_SW, GPIO.IN)
GPIO.setup(CAPTURE_SW, GPIO.IN)
GPIO.setup(RECORD_LED, GPIO.OUT)
GPIO.setup(READY_LED, GPIO.OUT)

def poweroff():
    call("nohup shutdown -P now", shell=True)

def check_free_space(minsz=10*MB):
    '''Ensure this application has enough free space to store captured
    video and pictures.'''
    statvfs=os.statvfs(OUT_DIR)
    freesz=statvfs.f_frsize * statvfs.f_bavail
    return freesz > minsz

def capture_picture():
    '''Capture a picture from the picam, using yyyy-MM-dd-hh-mm-ss.jpg
    as the filename format.'''
    fname = dt.datetime.now().strftime('%Y-%m-%d-%H-%M-%S') + ".jpg"
    path = os.path.join(CAP_DIR, fname)
    # with picamera.PiCamera() as cam:
    cam.resolution = STILL_RESOLUTION
    cam.start_preview()

    sleep(2)
    cam.capture(path)

def start_recording():
    '''Start recording a video from the picam, using yyyy-MM-dd-hh-mm-ss.h264
    as the filename format.'''
    fname = dt.datetime.now().strftime('%Y-%m-%d-%H-%M-%S') + ".h264"
    path = os.path.join(VID_DIR, fname)

    cam.resolution = VID_RESOLUTION
    cam.start_recording(path)

def stop_recording():
    '''Terminate a video recording in progress.'''
    cam.stop_recording()

# Setup the picam with some basic settings.
cam = picamera.PiCamera()
#cam.resolution = (1024,768)

# State for the loop to help us keep track of what's going on (recording in progress?)
# along with whether the record light is on or off.
recording=False
on=False

try:
    # Reflect that this application is ready for use, by printing to the console
    # AND lighting up an LED (since we'll be running headless most of the time).
    print "piclipse is ready"
    GPIO.output(READY_LED, 1)

    # Loop...endlessly. Check pin inputs and verify minimum disk availability 
    # with each loop.
    while True:

        # If the user presses record and capture simultaneously
        # and holds them for 2 seconds, poweroff.
        if GPIO.input(RECORD_SW) and GPIO.input(CAPTURE_SW):
            sleep(2)
            if GPIO.input(RECORD_SW) and GPIO.input(CAPTURE_SW):
                for _ in range(5):
                    GPIO.output(READY_LED, 1)
                    GPIO.output(RECORD_LED, 1)
                    sleep(0.5)
                    GPIO.output(READY_LED, 0)
                    GPIO.output(RECORD_LED, 0)
                    sleep(0.5)
                poweroff()

        # If we don't have enough free space, we should really quit.
        # HOWEVER, since this is designed to be managed by systemd,
        # AND since we'd want it to try to restart piclipse.py in
        # the event something unexpected happened, we can't really
        # exit here.
        #
        # Instead, let's turn off the ready LED and wait for a long
        # period, after which we'll find the same disk state and
        # wait again. And again.
        if not check_free_space():
            print "Out of space. Disabling picture / video capture."
            GPIO.output(READY_LED, 0)
            sleep(60)

        # If the user presses the record button, toggle video recording state
        # and start or stop the current recording.
        # Start the record LED flashing if we're starting a recording.
        # Stop it otherwise.
        # If we're starting a recording, turn off the ready LED. If stopping,
        # turn it back on.
        elif GPIO.input(RECORD_SW):
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

        # We're in the middle of recording a video...flash the LED
        # to give a visual signal that recording is in progress.
        elif recording:
            on = not on
            GPIO.output(RECORD_LED, on)

        # If we're not recording a video, and the user presses
        # the capture button, take a picture.
        # Turn on the record LED for a bit while this happens,
        # to give feedback. Then turn it off afterward.
        # The ready LED will be managed with the opposite states
        # as the record LED here.
        elif not recording and GPIO.input(CAPTURE_SW):
            print "Capturing still image"
            GPIO.output(RECORD_LED, 1)
            GPIO.output(READY_LED, 0)

            capture_picture()

            GPIO.output(RECORD_LED, 0)
            GPIO.output(READY_LED, 1)
            on = False

        # Some minimal sleep between input scans for CPU sanity.
        sleep(0.25)
finally:
    # Tidy up the camera and reset the GPIO states before we exit.
    if cam:
        cam.close()

    GPIO.cleanup()
