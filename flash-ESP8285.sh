#!/usr/bin/env bash

PORT="/dev/tty.SLAB_USBtoUART"
# PORT="/dev/tty.usbserial-141320"

# Note the -fm dout option is the important difference here.
esptool/esptool.py --port /dev/tty.wchusbserial142130 write_flash -fm dout 0x00000 builds/nodemcu-master-10-modules-2018-09-17-22-41-12-float.bin
