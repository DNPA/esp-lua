--Startup file--
print("Startup, version 2.7 (5 secs to act)")
wifi.setmode(wifi.STATION)

print("Mac: "..wifi.sta.getmac().. ", Mode: "..wifi.getmode())

tmr.alarm(0, 5000, 0, function() dofile("scan.lua") end)

print("End of startup")

