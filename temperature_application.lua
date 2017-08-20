-- load configuration, 'DWEET_FREQUENCY'
dofile("configuration.lua")
dofile("temperature_lib.lua")

-- dweets every DWEET_FREQUENCY seconds.
if tmr.alarm(0, DWEET_FREQUENCY * 1000, tmr.ALARM_AUTO, function() dweet(nil) end ) then
    print("Dweets every " .. DWEET_FREQUENCY .. " sec to dweet.io")
    print("Stop this by tmr.stop(0)")
else
    print("Problem starting timer!")
end

