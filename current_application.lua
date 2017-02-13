print("Measuring current ...")

function measure()
    print(adc.read(0))
end

tmr.alarm(0, 50, 1, function() measure() end )