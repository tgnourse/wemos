-- load configuration
dofile("configuration.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        file.close("init.lua")
        local file, err = loadfile(APPLICATION)
        if file then
            print("Running " .. APPLICATION)
            file()
        else
            print("There was an error opening " .. APPLICATION)
            print(err)
        end
    end
end

-- TODO: Set mode to STATIONAP when WIFI_STATION && WIFI_ACCESS_POINT.
if WIFI_STATION then
    print("Connecting to WiFi with SSID: " .. SSID)
    wifi.setmode(wifi.STATION)
    local cfg = {
        ssid = SSID,
        pwd = PASSWORD,
        save = false
    }
    wifi.sta.config(cfg)
    -- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
    tmr.alarm(1, 500, 1, function()
        if wifi.sta.getip() == nil then
            print("Waiting for IP address in WiFi mode: " .. wifi.getmode())
        else
            tmr.stop(1)
            print("WiFi connection established, IP address: " .. wifi.sta.getip())
            print("You have " .. STARTUP_DELAY .. " seconds to abort with tmr.stop(0)")
            tmr.alarm(0, STARTUP_DELAY * 1000, 0, startup)
        end
    end)
elseif WIFI_ACCESS_POINT then
    print("Setting as WiFi Access Poiint with SSID: " .. SSID .. " and password: " .. PASSWORD)
    wifi.setmode(wifi.SOFTAP)

    local cfg = {
        ssid = SSID,
        pwd = PASSWORD
    }
    wifi.ap.config(cfg, false)
    print("Access point mac: ", wifi.ap.getmac())
    startup()
else
    -- No WiFi startup
    print("You have " .. STARTUP_DELAY .. " seconds to abort with tmr.stop(0)")
    print("Waiting...")
    tmr.alarm(0, STARTUP_DELAY * 1000, 0, startup)
end