#!/usr/bin/env bash
git clone git@github.com:espressif/esptool.git
git clone git@github.com:kmpm/nodemcu-uploader.git
# Needed for nodemcu-uploader/nodemcu-uploader.py
pip install wrapt
# Needed for ls-serial.py
pip install pyserial
