#!/usr/bin/env bash

PORT="/dev/tty.wchusbserial14140"

python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload configuration.lua
python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload init.lua