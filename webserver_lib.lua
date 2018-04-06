-- load configuration, 'HTTP_PORT'

function parseUrl(payload)
    local e = payload:find("\r\n", 1, true)
    if not e then return nil end
    local line = payload:sub(1, e - 1)
    local r = {}
    _, i, r.method, r.request = line:find("^([A-Z]+) (.-) HTTP/[1-9]+.[0-9]+$")
    return r.request
end

function setUpWebServer(routes)
    -- Start an HTTP server.
    print("Starting HTTP server on port " .. HTTP_PORT)
    srv=net.createServer(net.TCP)
    srv:listen(HTTP_PORT, function(conn)
        conn:on("receive", function(conn, payload)
            print("receive:")
            local url = parseUrl(payload)
            local body = ""
            if routes[url] then
                body = routes[url]()
            else
                body = routes["/"]()
            end
            local http_body = "<html><body>" .. body .. "</body></html>\n"
            -- Need some minimal headers to be valid HTTP. Some clients work with just content back
            -- but some (like Safari) don't.
            local http_response = "HTTP/1.1 200 OK\n" ..
                    "Content-Length: " .. http_body:len() .. "\n" ..
                    "Content-Type: text/html\n\n" ..
                    http_body
            conn:send(http_response)
        end)
        conn:on("sent", function(conn)
            conn:close()
        end)
    end)
end