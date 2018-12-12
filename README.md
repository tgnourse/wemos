# Summary
A collection of applications for the Wemos D1 Mini running NodeMcu. Note that this isn't super user friendly yet but it should be possible to get this running on your own.

## Applications
* `current_applicatiion.lua` - Unifinished, attempting to read and report A/C current measurements.
* `lowpower_application.lua` - Low power temperature reporting. Nicer than normal temperature reporting because it doesn't require any insulation between the SHT20 and the Wemos board.
* `on_application.lua` - Calls a specified endpoint at a regular interval. Pairs well with the `/on5` endpoint of the `relay_application.lua`.
* `relay_application.lua` - Exposes a web server for control of a relay with endpoints like `/on`, `/off`, and `/on5`.
* `temperature_application.lua` - Temperature reporting. Requires inslutation between the Wemos D1miniPRo and the SHT30 because the former heats up the latter since it doesn't go to sleep.

## How To

### Install the Tools
Install esptool (flasher) & nodemcu-uploader (file upload, etc.), and `pip install wrapt`
```
> ./install.sh 
  Cloning into 'esptool'...
  ...
  Resolving deltas: 100% (1069/1069), done.
  Cloning into 'nodemcu-uploader'...
  ...
  Resolving deltas: 100% (428/428), done.
  ...
  Successfully installed wrapt-1.10.11
```

### Flash
Only needs to happen once, make sure to pick the right chip. May need to change the serial port in `flash.sh` or just run the command yourself. See the [NodeMCU Docs](https://nodemcu.readthedocs.io/en/master/en/flash/#esptool) for more.
```
> ./flash-ESP8266.sh
  ...
  Hash of data verified.
  
  Leaving...
  Hard resetting via RTS pin...
```

### Serial Monitor
You should see this after resetting the Wemos and it's formatting.
```
> python nodemcu-uploader/nodemcu-uploader.py --port /dev/tty.wchusbserial14140 terminal
  ...
  Formatting file system. Please wait...
```

And after it's done (and you're ready to go) you should finally see. If you try to do anything before this it won't work.
```
  lua: cannot open init.lua
```

### Configuration
Needs a `configuration.lua` defined with the various variables needed by each of the applications. This can look something like this:
```
-- init.lua
------------------------------
WIFI_STATION = true
SSID = "YourNetwork"
PASSWORD = "P@55W0RD"

-- The application you want to run
APPLICATION = "lowpower_application.lua"
STARTUP_DELAY = 5 -- seconds

-- temperature_lib.lua
------------------------------
TEMPERATURE_DIFF = 0 -- degrees F
HUMIDITY_DIFF = 0 -- RH %
THING = "your_thing_id"
FREQUENCY = 300 -- seconds
```

### Upload
Either upload files one by one or use the script `./upload.sh`. If you're having trouble uploading a file due to timeouts or whatever, it helps to remove the `init.lua`.
