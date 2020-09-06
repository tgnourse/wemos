#!/usr/bin/env bash
python3 esptool/esptool.py --port /dev/tty.usbserial-142320 write_flash -fm dio 0x00000 builds/nodemcu-master-10-modules-2018-09-17-22-41-12-float.bin
