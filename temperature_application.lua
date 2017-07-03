-- load configuration, 'THING', 'TEMPERATURE_DIFF', 'HUMIDITY_DIFF', 'DWEET_FREQUENCY'
dofile("configuration.lua")

function dweet()
    print("Connecting to sensor ...")

    -- ID is always 0
    local ID = 0
    -- Defined by the SHT30 shield, 0x45
    local ADDRESS = 69
    -- Defined by the SHT30 shield
    local SC1 = 1
    local SDA = 2

    i2c.setup(ID, SDA, SC1, i2c.SLOW)

    i2c.start(ID)
    if i2c.address(ID, ADDRESS, i2c.TRANSMITTER) then
        print "ACK received"
    else
        print "No ACK received"
    end
    local wrote = i2c.write(ID, 0x2C, 0x06)
    i2c.stop(ID)
    print(wrote)

    i2c.start(ID)
    if i2c.address(ID, ADDRESS, i2c.RECEIVER) then
        print "ACK received"
    else
        print "No ACK received"
    end
    local result = i2c.read(ID, 6)
    i2c.stop(ID)

    if result then
        print(string.byte(result, 1))
        print(string.byte(result, 2))
        print(string.byte(result, 3))
        print(string.byte(result, 4))
        print(string.byte(result, 5))
        print(string.byte(result, 6))

        local cTemp = ((((string.byte(result, 1) * 256.0) + string.byte(result, 2)) * 175) / 65535.0) - 45;
        print(cTemp)
        local fTemp = (cTemp * 1.8) + 32;
        print(fTemp)
        local humidity = ((((string.byte(result, 4) * 256.0) + string.byte(result, 5)) * 100) / 65535.0);
        print(humidity)

        local HOST = "dweet.io"
        local conn = net.createConnection(net.TCP,0)
        conn:on("receive", function(conn, pl) print("response: ",pl) end)
        conn:on("connection", function(conn, payload)
            print("connected")
            conn:send("POST /dweet/for/" .. THING
                    .. "?"
                    .. "temperature=" .. (fTemp + TEMPERATURE_DIFF)
                    .. "&hum=" .. (humidity + HUMIDITY_DIFF)
                    .. "&heap=" .. node.heap()
                    .. "&ip=" .. wifi.sta.getip()
                    .. "&ssid=" .. SSID
                    .. " HTTP/1.1\r\n"
                    .. "Host: " .. HOST .. "\r\n"
                    .. "Connection: close\r\n"
                    .. "Accept: */*\r\n\r\n") end)
        conn:on("disconnection", function(conn, payload)
            print("disconnected") end)
        conn:connect(80, HOST)
    else
        print "No result received"
    end
end

-- dweets every DWEET_FREQUENCY seconds.
if tmr.alarm(0, DWEET_FREQUENCY * 1000, tmr.ALARM_AUTO, function() dweet() end ) then
    print("Dweets every " .. DWEET_FREQUENCY .. " sec to dweet.io")
    print("Stop this by tmr.stop(0)")
else
    print("Problem starting timer!")
end

