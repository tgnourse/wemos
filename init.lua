-- load credentials, 'SSID' and 'PASSWORD'
dofile("credentials.lua")

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        file.close("init.lua")
        -- the actual application is stored in 'application.lua'
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

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID, PASSWORD)
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
        print("Waiting for IP address...")
    else
        tmr.stop(1)
        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        print("You have 5 seconds to abort")
        print("Waiting...")
        tmr.alarm(0, 5000, 0, startup)
    end
end)

-- No WiFi startup
--print("You have 3 seconds to abort")
--print("Waiting...")
--tmr.alarm(0, 3000, 0, startup)