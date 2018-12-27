-- load configuration, 'SSID', 'HOST', 'URL', 'THING'

local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
end

local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
end

local urldecode = function(url)
    if url == nil then
        return
    end
    url = url:gsub("+", " ")
    url = url:gsub("%%(%x%x)", hex_to_char)
    return url
end

-- ref: https://gist.github.com/ignisdesign/4323051
-- ref: http://stackoverflow.com/questions/20282054/how-to-urldecode-a-request-uri-string-in-lua
-- to encode table as parameters, see https://github.com/stuartpb/tvtropes-lua/blob/master/urlencode.lua

function sht30()
    -- ID is always 0, doesn't matter the device.
    local ID = 0
    -- Defined by the SHT30 shield, 0x45
    local SHT30_ADDRESS = 69
    -- Defined by the SHT30 shield
    local SDA = 2
    local SCL = 1

    i2c.setup(ID, SDA, SCL, i2c.SLOW)

    i2c.start(ID)
    i2c.address(ID, SHT30_ADDRESS, i2c.TRANSMITTER)
    i2c.write(ID, 0x2C, 0x06)
    i2c.stop(ID)

    i2c.start(ID)
    i2c.address(ID, SHT30_ADDRESS, i2c.RECEIVER)
    local result = i2c.read(ID, 6)
    i2c.stop(ID)

    if result then
        local cTemp = ((((string.byte(result, 1) * 256.0) + string.byte(result, 2)) * 175) / 65535.0) - 45
        local fTemp = (cTemp * 1.8) + 32
        local humidity = ((((string.byte(result, 4) * 256.0) + string.byte(result, 5)) * 100) / 65535.0)
        return cTemp, fTemp, humidity
    end

    return nil, nil, nil
end

function bmp180()
    local OSS = 1 -- oversampling setting (0-3)
    local SDA_PIN = 2 -- sda pin, GPIO2
    local SCL_PIN = 1 -- scl pin, GPIO15

    bmp180 = require("bmp180")
    bmp180.init(SDA_PIN, SCL_PIN)
    bmp180.read(OSS)
    local t = bmp180.getTemperature()
    local p = bmp180.getPressure()
    -- release module
    bmp180 = nil
    package.loaded["bmp180"]=nil
    return t, (t * 1.8) + 32, p
end

function dweet(callback)
    local cTemp, fTemp, humidity = sht30()
    local pcTemp, pfTemp, pressure = bmp180()
    if cTemp then

        -- Get the various WiFi information.
        local heap = node.heap()
        print(heap)
        local ip = wifi.sta.getip()
        print(ip)
        local ssid = SSID
        print (ssid)

        -- TODO: Create a iotupload_lib.lua and separate temperature code from the IoT upload code.
        -- local HOST = "dweet.io"
        -- conn:send("POST /dweet/for/" .. THING
        local http_request = "POST " .. URL
                .. "?"
                .. "sensor_id=" .. THING
                .. "&temperature=" .. fTemp
                .. "&hum=" .. humidity
                .. "&heap=" .. heap
                .. "&ip=" .. ip
                .. "&ssid=" .. urlencode(ssid)
                .. "&pressure_temperature=" .. pfTemp
                .. "&pressure=" .. pressure / 3386.389 -- convert pa to inHg
                .. " HTTP/1.1\r\n"
                .. "Host: " .. HOST .. "\r\n"
                .. "Content-Length: 0\r\n"
                .. "Connection: close\r\n"
                .. "Accept: */*\r\n\r\n"
        print("HTTP Request: ")
        print(http_request)

        print("Setting up connection ...")

        local conn = net.createConnection(net.TCP, 0)
        conn:on("connection", function(conn, payload)
            print("Sending ...")

            conn:send(http_request)
        end)
        conn:on("receive", function(conn, pl)
            print("response: ", pl)
            -- Only call the callback AFTER we've received a response
            if callback then
                callback()
            end
        end)
        conn:connect(80, HOST)
    else
        print "No result received from the sensor, giving up!"
        -- If we can't read from the sensor, call the callback
        if callback then
            callback()
        end
    end
end