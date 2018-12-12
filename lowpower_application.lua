-- load configuration, 'FREQUENCY'
dofile("configuration.lua")
dofile("temperature_lib.lua")

-- Add a watch dog that restarts in 20 seconds in case the network call gets stuck, which appears to
-- happen every now and again.
tmr.softwd(20)
dweet(function ()
    tmr.softwd(-1)
    print("Going to sleep for " .. FREQUENCY .. " seconds.")
    node.dsleep(FREQUENCY * 1000 * 1000, nil, nil)
end)
