
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

function parseUrl(payload)
    local e = payload:find("\r\n", 1, true)
    if not e then return nil end
    local line = payload:sub(1, e - 1)
    local r = {}
    _, i, r.method, r.request = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[0-9]+$")
    return r.request
end

function onView()
    on()
    return ""
end

-- TODO(tgnourse): This seems to crap out and stop turning off after it's left for a "while".
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

-- Start an HTTP server for controlling the relay.
print("Starting relay server ...")
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn, payload)
        local url = parseUrl(payload)
        local body = ""
        if url == "/on" then
            body = onView() .. defaultView()
        elseif url == "/off" then
            body = offView() .. defaultView()
        elseif url == "/on5" then
            body = onFiveView() .. defaultView()
        else
            body = defaultView()
        end
        conn:send("<html><body>" .. body .. "</body></html>")
    end)
    conn:on("sent",function(conn) conn:close() end)
end)


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
                .. " HTTP/1.1\r\n"
                .. "Host: " .. HOST .. "\r\n"
                .. "Connection: close\r\n"
                .. "Accept: */*\r\n\r\n") end)
    conn:on("disconnection", function(conn, payload)
        print("disconnected") end)
    conn:connect(80, HOST)
end

-- dweets every DWEET_FREQUENCY seconds.
if tmr.alarm(DWEET_TIMER_ID, DWEET_FREQUENCY * 1000, tmr.ALARM_AUTO, function() callDweet() end ) then
    print("Dweets every " .. DWEET_FREQUENCY .. " seconds to dweet.io as " .. THING)
    print("Stop this by tmr.stop(1)")
else
    print("Problem starting DWEET timer!")
end