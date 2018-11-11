#!/usr/bin/env bash
# Note the -fm dout option is the important difference here.
esptool/esptool.py --port /dev/tty.wchusbserial14140 write_flash -fm dout 0x00000 builds/nodemcu-master-10-modules-2018-09-17-22-41-12-float.bin
