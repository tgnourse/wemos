# Summary
A collection of applications for the Wemos D1 Mini running NodeMcu. Note that this isn't super user friendly yet but it should be possible to get this running on your own.

## Applications
* `current_applicatiion.lua` - Unifinished, attempting to read and report A/C current measurements.
* `lowpower_application.lua` - Low power temperature reporting. Nicer than normal temperature reporting because it doesn't require any insulation between the SHT20 and the Wemos board.
* `on_application.lua` - Calls a specified endpoint at a regular interval. Pairs well with the `/on5` endpoint of the `relay_application.lua`.
* `replay_application.lua` - Exposes a web server for control of a relay with endpoints like `/on`, `/off`, and `/on5`.
* `temperature_applicatio.lua` - Temperature reporting. Requires inslutation between the Wemos D1miniPRo and the SHT30 because the former heats up the latter since it doesn't go to sleep.

## How To
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
DWEET_FREQUENCY = 300 -- seconds
```