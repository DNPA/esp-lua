-- choose the strongest open AP available and connect to it
-- tested with NodeMcu x.y.z

Tstart  = tmr.now()

apslist = nil

connectToAP = nil
function connectToAP(n, _aplist)
   status = wifi.sta.status()
   uart.write(0,''..status)
   local x = n+1
   if (x < 10) and ( status < 5 ) then
      tmr.stop(0)
      tmr.alarm(0,1000,0,function() connectToAP(x,_aplist) end)
   else
      if status == 5 then
        print('\nConnected as '..wifi.sta.getip().. ", Heap: "..node.heap())
        apslist = _aplist
        dofile('senddata.lua')
        tmr.stop(0)
        tmr.alarm(0,2000,0,function() scanForAPs() end)
        --tmr.alarm(0,2000,0,function()  print("oeps") node.restart() end)
      else
        print("\nConnection failed")
        teller=0
        tmr.stop(0)
        tmr.alarm(0,2000,0,function() scanForAPs() end)
      end
   end
end
   
findStrongestSSID = nil
function findStrongestSSID(ap_db)
   local min = 100
   ssid = nil
   for k,v in pairs(ap_db) do
       if tonumber(v) < min then 
          min = tonumber(v)
          ssid = k
          end
       end
   return min
end

teller=0
processAPs = nil
function processAPs(aplist)
   if aplist == nil then
     print("No Access Points, Count: "..teller..", Heap: "..node.heap())
     teller = teller+1
     tmr.stop(0)
     tmr.alarm(0,2000,0,function() scanForAPs() end)
   else
       print("Access Points found:")
       for k,v in pairs(aplist) do print(k..' '..v) end
       ap_db = {}
       if next(aplist) then
          for k,v in pairs(aplist) do 
             if '0' == string.sub(v,1,1) then 
                ap_db[k] = string.match(v, '-(%d+),') 
             end 
          end
          print("Open Available Access Points:")
          for o,p in pairs(ap_db) do
            print(o..', '..-p)
          end             
          signal = -findStrongestSSID(ap_db)
          --ssid = "Gasten"
       end
       if ssid then
          print("Connecting to Best SSID: "..ssid..", Heap: "..node.heap())
          wifi.sta.config(ssid,"\000\000\000\000\000\000\000\000\000")
          --wifi.sta.connect() -- Kan je ook weglaten !
          connectToAP(0, aplist)
       else
          print("No (strong) available open APs")
          ssid = ''
       end
   end
end
    
scanForAPs = nil
function scanForAPs()
    print ("(Re)scanning..., Heap: "..node.heap())
    aplist=nil
    apslist=nil
    wifi.sta.disconnect()
    wifi.setmode(wifi.STATION)
    collectgarbage() 
    print ("(Re)scanning..., Heap: "..node.heap())
    
    wifi.sta.getap(processAPs)
end

wifi.setmode(wifi.STATION)
--wifi.sta.getap(function(t) strongest(t)  end)
print ("Start scanning 3.3.3...")
scanForAPs()

