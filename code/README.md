# Python Code for Pinoc Picture / Video Capture System for Binoculars / Telescopes

This application is designed to allow Raspberry Pi single-board computers to be mounted on binoculars (or, really anything like that...telescopes for instance). It uses the RPi GPIO interface to read input signals
from momentary buttons (wired to GPIO/BCM 22 & 27), and output status to two LEDs (GPIO/BCM 17 & 24).

Pinoc relies on the use of a Raspberry Pi camera module, which wires directly into the board via ribbon cable. It uses the `picamera` Python 2 module to interface with the hardware.

## Installation

The only thing you really need installed is the python-picamera package:

```
    $ sudo apt-get install python-picamera
```

However, if you're setting up a new Raspberry Pi and intend to use it with Pinoc, you might want to check out the Ansible playbook (under `ansible/pinoc.playbook.yml`) instead. To use it, you'll need to fill out the IP address of your Raspberry Pi in `ansible/hosts`, in place of the `x.x.x.x` placeholder. Then, you should be able to simply call:

```
    $ ansible-playbook -i ./ansible/hosts ansible/pinoc.playbook.yml
```

It will probably prompt you for your `pi` user password, unless you've previously installed a SSH public key on your RPi.

**NOTE:** This does rely on having SSH enabled on your RPi, which means you'll also need to set the `pi` user's password to some non-default value to maintain some semblance of security.

Ansible will install a systemd service definition for Pinoc, and enable it by default. That means Pinoc will automatically start with the system whenever it boots.

If you would rather start it another way, the general command line is:

```
    $ ./pinoc.py <output-directory>
```

## Switches

GPIO/BCM pin 22 is wired to a momentary switch that is used to toggle video recording on / off. Pin 27 is used to trigger the capture of a still image.

*If you press and hold both pins for 2 seconds or more*, the system will shutdown. This is an especially important feature since we don't have a console, and in the case of a RPi Zero, maybe not even a network connection. So, without this feature, there's no way to cleanly shutdown the system.

## LEDs

The LED wired to pin 17 (GPIO/BCM) is a recording status light. Think of those flashing signs above the doors of recording studios. When Pinoc is capturing a video or still image, this LED will be lit (either solid or flashing).

By contrast, the LED wired to pin 24 is a ready indicator. This lets you know Pinoc is up and running and waiting for input from your buttons. It's important to have this, since your RPi will probably be running in headless mode (no console or screen available), and without it you'll have no idea whether you're ready to capture that amazing eclipse in front of you!

## Other Things

Another thing I've done on my own install is to wire another LED between pin 14 (GPIO/BCM), which is the serial console's TX (transmit) pin, and ground (the pin next to it, as you head toward the near corner of the board, is convenient). This LED will shine as long as it's **unsafe** to power off your RPi, and turn off when it's generally safe to pull the plug. Again, when you don't have a console or screen, it can be hard to know when you can power off your board without causing filesystem corruption. This helps.

To be **really** safe here, you might even put a capacitor inline, so the LED remains illuminated a bit beyond shutdown of the serial console interface. If you watch the green LED on the RPi board itself, it will blink about 10 times starting when this TX LED goes off. I'm not sure what this indicates, but after 10 blinks it stops, which I interpret to mean that's when it's safe to cut power. With the right capacitor on the TX LED, you could potentially keep it on long enough to span that blinking period, and turn off around the same time.

## Don't Forget the Resistors!

With LEDs, you'll need a nice, low-valued resistor. I used 330 Ohm, which seemed to work well.

For switches, you want to tie them to the opposite voltage you consider "on". In the case of this application, it was convenient to consider logical HIGH (5v power) to be "on" for the switch, which meant I tied the switch output pins (the pins I was scanning) to LOW (ground). This prevents spurious voltages from causing a false signal that looks like your switches being triggered.

Use a nice, high-valued resistor for your switches. I used a 10k, which seems to work well enough.
