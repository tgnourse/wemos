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
    wifi.sta.config(SSID, PASSWORD)
    -- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
    tmr.alarm(1, 500, 1, function()
        if wifi.sta.getip() == nil then
            print("Waiting for IP address in WiFi mode: " .. wifi.getmode())
        else
            tmr.stop(1)
            print("WiFi connection established, IP address: " .. wifi.sta.getip())
            print("You have " .. STARTUP_DELAY .. " seconds to abort")
            print("Waiting...")
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

    -- TODO: These don't work for some reason, firmware issue? Not necessary but would be nice.
--    wifi.ap.on("sta_connected", function(ev, info)
--        print("sta_connected")
--        print("sta_connected mac: ", info.mac, "id: ", info.id)
--    end)
--
--    wifi.ap.on("sta_disconnected", function(ev, info)
--        print("sta_disconnected")
--        print("sta_disconnected mac: ", info.mac, "id: ", info.id)
--    end)
--
--    wifi.ap.on("probe_req", function(ev, info)
--        print("probe_req")
--        print("probe_req from: ", info.from, "rssi: ", info.rssi)
--    end)
--
--    wifi.ap.on("start", function(ev, info)
--        print("start")
--        print("access point mac: ", wifi.ap.getmac())
--    end)
--
--    wifi.ap.on("stop", function(ev, info)
--        print("stop")
--        print("access point mac: ", wifi.ap.getmac())
--    end)
    startup()
else
    -- No WiFi startup
    print("You have " .. STARTUP_DELAY .. " seconds to abort")
    print("Waiting...")
    tmr.alarm(0, STARTUP_DELAY * 1000, 0, startup)
end