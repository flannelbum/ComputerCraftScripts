--name chatAPI

function apiver()
  APIversion = "v0.11"
  return APIversion
end

function whoami()
  id = os.getComputerID()
  aka = os.getComputerLabel()
  master = getMaster()
  if aka == nil then
    aka = "UNNAMED!"
  end
  if master == nil then
    master = "Claude Rains"
    return id, aka, master
  end
end


function getMaster()
  if fs.exists("master") == true then
    f = fs.open("master", "r")
    master = f.readLine()
    f.close()
    return master
  else
    return master -- maybe it's set already?
  end
end

function openModem()
  for i, v in pairs(rs.getSides()) do
    if peripheral.getType(v) == "modem" then
      if not rednet.isOpen(v) then
        rednet.open(v)
      end
    return true
    end
  end
  return false
end

function msgchk(fromID, msg, dist)
-- all loops must return false to prevent refresh
  me, aka, master = whoami()
  
  -- ignore the shit I say
  if fromID ~= me then
    
    -- Global msgs.
    if msg == "who" then
      rednet.send(fromID, "I am: "..id.." My name is: "..aka.."\nMy master is: "..master.."\nYou appear to be "..dist.." blocks away")
    end
    
    
    --any msg from master
    if fromID == master then
      --mobility stuff.. direction/turn/repeat
      rednet.send(fromID, "I hear you, master ("..master..")")
    end
    
    --msgs starting with my id
    if msg == tostring(me) then
      rednet.send(fromID, "Yes?")
    end

    if msg == "FAR" then
      return true
    end
    
    return false
  end
end

function speak(msg)
 if msg ~= nill then
  rednet.broadcast(msg)
 else
  msg = tostring(read())
  rednet.broadcast(msg) 
 end
end


