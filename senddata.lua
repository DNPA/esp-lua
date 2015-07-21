
domain_suffix = "l.hec.to"

function send_data()
  scanid = tmr.now()
  loopcounter = 4
  local k, v
  for k, v in pairs(apslist) do
    loopcounter = loopcounter - 1
    if loopcounter >= 0 then 
      print("Make DNS Record for "..k) 
      local enc, rssi, bssid, chan = string.match(v,
        "(%d),(-?%d+),([%x:]+),(%d+)")
      local dnsq = "s"..rssi.."."..bssid.gsub(bssid, ":", "") ..
                   "."..scanid.."."..node.chipid().."."..domain_suffix
      sk = net.createConnection(net.UDP, false)
      sk:dns(dnsq, 
        function (s, i) 
          print("Sent "..dnsq.." for "..k)
        end)
    end
  end
  sk = nil
  print("DNS Records placed in sent queue, Heap: "..node.heap())
end

send_data()
