-- load configuration, 'DWEET_FREQUENCY'
dofile("configuration.lua")
dofile("temperature_lib.lua")

-- Add a watch dog that restarts in 20 seconds in case the network call gets stuck, which appears to
-- happen every now and again.
tmr.softwd(20)
dweet(function ()
    tmr.softwd(-1)
    print("Going to sleep for " .. DWEET_FREQUENCY .. " seconds.")
    node.dsleep(DWEET_FREQUENCY * 1000 * 1000, nil, nil)
end)
