# Python Code for Pinoc Picture / Video Capture System for Binoculars / Telescopes

This application is designed to allow Raspberry Pi single-board computers to be mounted on binoculars (or, really anything like that...telescopes for instance). It uses the RPi GPIO interface to read input signals
from momentary buttons (wired to GPIO/BCM 22 & 27), and output status to two LEDs (GPIO/BCM 17 & 24).

Pinoc relies on the use of a Raspberry Pi camera module, which wires directly into the board via ribbon cable. It uses the `picamera` Python 2 module to interface with the hardware.

# Software

The software for this system centers on a small python app called `pinoc.py`, which is located in the `code/` directory. It can be installed using Ansible, via the playbook in the `ansible/` directory. You'll find instructions for installing the software (including using the Ansible playbook) in the [README.md under code/](code/).

The software README also contains instructions for wiring the buttons and LEDs to the RPi.

# Printed Fittings

In addition to software, you also need a place to hold buttons, LEDs, a Raspberry Pi, and a battery. The CAD and STL files for those are contained in `cad/` and `cad/stl/`, respectively. See [README.md under cad/](cad/) for more information on how to use those files.
