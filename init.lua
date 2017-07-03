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

if WIFI then
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
else
    -- No WiFi startup
    print("You have " .. STARTUP_DELAY .. " seconds to abort")
    print("Waiting...")
    tmr.alarm(0, STARTUP_DELAY * 1000, 0, startup)
end