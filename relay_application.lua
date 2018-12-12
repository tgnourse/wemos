-- load configuration, 'THING', 'FREQUENCY'

local PIN = 1
local status = false
gpio.mode(PIN, gpio.OUTPUT)
local TIMER_ID = 0
local DWEET_TIMER_ID = 1

function on()
    print("Turning relay on ...")
    status = true
    gpio.write(PIN, gpio.HIGH)
end

function off()
    print("Turning relay off ...")
    status = false
    gpio.write(PIN, gpio.LOW)
end

function onView()
    on()
    return ""
end

function onFiveView()
    on()
    -- Set a time that'll turn the relay off in 5 seconds
    print("Scheduled to turn off in 5 seconds ...")
    if tmr.state(TIMER_ID) then
        print("tmr.stop() result: " .. tostring(tmr.stop(TIMER_ID)))
        tmr.interval(TIMER_ID, 5 * 1000)
        print("tmr.start() result: " .. tostring(tmr.start(TIMER_ID)))
    else
        tmr.register(TIMER_ID, 5 * 1000, tmr.ALARM_SINGLE, function() off() end )
        print("tmr.start() result: " .. tostring(tmr.start(TIMER_ID)))
    end
    return ""
end

function offView()
    off()
    return ""
end

function statusHTML(status)
    if status then
        return "<span style=\"color:green\">ON</span>"
    end
    return "<span style=\"color:red\">OFF</span>"
end

function defaultView()
    return "<h1>Welcome to the relay!</h1>" ..
            "<h2>Status: " .. statusHTML(status) .. "</h2>" ..
            "<ul>" ..
                "<li><a href=\"/on\">Turn on</a></li>" ..
                "<li><a href=\"/on5\">Turn on for 5 seconds</a></li>" ..
                "<li><a href=\"/off\">Turn off</a></li>" ..
            "</ul>"

end

dofile("webserver_lib.lua")

routes = {
    ["/on"] = function () return onView() .. defaultView() end,
    ["/off"] = function () return offView() .. defaultView() end,
    ["/on5"] = function () return onFiveView() .. defaultView() end,
    ["/"] = function () return defaultView() end,
}

-- Start the web server.
setUpWebServer(routes)

-- TODO: Pull this out into it's own lib file and reuse.
function callDweet()
    print("Dweeting ...")

    local HOST = "dweet.io"
    local conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, pl) print("response: ",pl) end)
    conn:on("connection", function(conn, payload)
        print("connected")
        conn:send("POST /dweet/for/" .. THING
                .. "?"
                .. "&on=" .. tostring(status)
                .. "&heap=" .. node.heap()
                .. "&ssid=" .. SSID
                .. "&ip=" .. wifi.sta.getip()
                .. " HTTP/1.1\r\n"
                .. "Host: " .. HOST .. "\r\n"
                .. "Connection: close\r\n"
                .. "Accept: */*\r\n\r\n") end)
    conn:on("disconnection", function(conn, payload)
        print("disconnected") end)
    conn:connect(80, HOST)
end

-- Only try to dweet if we're connected to the internet (i.e. a WiFi station).
if WIFI_STATION then
    -- dweets every FREQUENCY seconds.
    if tmr.alarm(DWEET_TIMER_ID, FREQUENCY * 1000, tmr.ALARM_AUTO, function() callDweet() end ) then
        print("Dweets every " .. FREQUENCY .. " seconds to dweet.io as " .. THING)
        print("Stop this by tmr.stop(1)")
    else
        print("Problem starting DWEET timer!")
    end
end