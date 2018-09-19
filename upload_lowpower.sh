#!/usr/bin/env bash

# Upload all files for the lowpower application.
python ../nodemcu-uploader/nodemcu-uploader.py upload init.lua
python ../nodemcu-uploader/nodemcu-uploader.py upload configuration.lua
python ../nodemcu-uploader/nodemcu-uploader.py upload lowpower_application.lua
python ../nodemcu-uploader/nodemcu-uploader.py upload temperature_lib.lua
