#!/usr/bin/env bash

PORT="/dev/tty.SLAB_USBtoUART"
# PORT="/dev/tty.usbserial-141320"

python3 nodemcu-uploader/nodemcu-uploader.py --port=${PORT} terminal