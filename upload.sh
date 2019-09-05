#!/usr/bin/env bash

PORT="/dev/tty.SLAB_USBtoUART"
# PORT="/dev/tty.usbserial-141320"

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
    python3 nodemcu-uploader/nodemcu-uploader.py --port=${PORT} upload ${i}
    ls -l ${i}
done
python3 nodemcu-uploader/nodemcu-uploader.py --port=${PORT} file list