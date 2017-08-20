-- load configuration, 'DWEET_FREQUENCY'
dofile("configuration.lua")
dofile("temperature_lib.lua")

dweet(function ()
    print("Going to sleep for " .. DWEET_FREQUENCY .. " seconds.")
    node.dsleep(DWEET_FREQUENCY * 1000 * 1000, nil, nil)
end)
