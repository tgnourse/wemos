-- load configuration, 'THING', 'TEMPERATURE_DIFF', 'HUMIDITY_DIFF'

function dweet(callback)
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
        local fTemp = (cTemp * 1.8) + 32;
        print(fTemp)
        local humidity = ((((string.byte(result, 4) * 256.0) + string.byte(result, 5)) * 100) / 65535.0);
        print(humidity)

        print("Dweeting ...")
        local HOST = "dweet.io"
        local conn = net.createConnection(net.TCP,0)
        conn:on("connection", function(conn, payload)
            print("sending ...")
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
                    .. "Accept: */*\r\n\r\n")
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
        print "No result received from the senseor, giving up!"
        -- If we can't read from the sensor, call the callback
        if callback then
            callback()
        end
    end
end