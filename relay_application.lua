
local PIN = 1
local status = false
gpio.mode(PIN, gpio.OUTPUT)

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
                "<li><a href=\"/off\">Turn off</a></li>" ..
            "</ul>"

end

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn, payload)
        local url = parseUrl(payload)
        local body = ""
        if url == "/on" then
            body = onView() .. defaultView()
        elseif url == "/off" then
            body = offView() .. defaultView()
        else
            body = defaultView()
        end
        conn:send("<html><body>" .. body .. "</body></html>")
        conn:close()
    end)
end)