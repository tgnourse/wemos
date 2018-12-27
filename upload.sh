#!/usr/bin/env bash

PORT="/dev/tty.wchusbserial142130"

declare -a arr=(
    "i2c.lua"
    "sensors.lua"
    "bmp180.lua"
    "temperature_lib.lua"
    "lowpower_application.lua"
    "configuration.lua"
    "init.lua"
)

for i in "${arr[@]}"
do
    echo "Uploading: $i"
    # or do whatever with individual element of the array
    python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload ${i}
    ls -l ${i}
done
python nodemcu-uploader/nodemcu-uploader.py --port=${PORT} file list