#!/usr/bin/env bash

PORT="/dev/tty.wchusbserial14140"

# Upload all files for the lowpower application.
python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload configuration.lua
python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload init.lua
python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload lowpower_application.lua
python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload temperature_lib.lua
