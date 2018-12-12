-- load configuration, 'THING', 'FREQUENCY', 'URL_HOST', 'URL_PATH', 'URL_FREQUENCY'
dofile("configuration.lua")

function callDweet()
    print("Dweeting ...")

    local HOST = "dweet.io"
    local conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, pl) print("response: ",pl) end)
    conn:on("connection", function(conn, payload)
        print("connected")
        conn:send("POST /dweet/for/" .. THING
                .. "?"
                .. "&on=1"
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
end

function callURL()
    print("Calling URL ... " .. URL_HOST .. "/" .. URL_PATH)

    local conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, pl) print("response: ",pl) end)
    conn:on("connection", function(conn, payload)
        print("connected")
        conn:send("GET /" .. URL_PATH
                .. " HTTP/1.1\r\n"
                .. "Host: " .. URL_HOST .. "\r\n"
                .. "Connection: close\r\n"
                .. "Accept: */*\r\n\r\n") end)
    conn:on("disconnection", function(conn, payload)
        print("disconnected") end)
    conn:connect(80, URL_HOST)
end

-- Start with the frequency values so the first beat triggers the functions.
local urlBeatCount = URL_FREQUENCY
local dweetBeatCount = FREQUENCY

function beat()
    if urlBeatCount >= URL_FREQUENCY then
        callURL()
        urlBeatCount = 0
    end
    urlBeatCount = urlBeatCount + 1

    if dweetBeatCount >= FREQUENCY then
        callDweet()
        dweetBeatCount = 0
    end
    dweetBeatCount = dweetBeatCount + 1
end

-- Once beat to start it off since we don't want to wait 1 second.
beat()

-- Now set up the hearbeat alarm.
if tmr.alarm(0, 1000, tmr.ALARM_AUTO, function() beat() end ) then
    print("Dweets every " .. FREQUENCY .. " seconds to dweet.io as " .. THING)
    print("Request every " .. URL_FREQUENCY .. " seconds to " .. URL_HOST .. "/" .. URL_PATH)
    print("Hearbeat timer every 1 second")
    print("Stop this by tmr.stop(0)")
else
    print("Problem starting hearbeat timer!")
end

-- dweets every FREQUENCY seconds.
--if tmr.alarm(0, FREQUENCY * 1000, tmr.ALARM_AUTO, function() callDweet() end ) then

--    print("Stop this by tmr.stop(0)")
--else
--    print("Problem starting DWEET timer!")
--end

-- calls the specified URL_HOST/URL_PATH every URL_FREQUENCY seconds.
--if tmr.alarm(1, URL_FREQUENCY * 1000, tmr.ALARM_AUTO, function() callURL() end ) then
--    print("Request every " .. URL_FREQUENCY .. " seconds to " .. URL_HOST .. "/" .. URL_PATH)
--    print("Stop this by tmr.stop(1)")
--else
--    print("Problem starting URL timer!")
--end


