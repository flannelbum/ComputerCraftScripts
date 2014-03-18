-- shoutRoute.lua
-- routs shouts ya'll

-- assumes the shoutIncludes.lua is loaded as shoutAPI and has already opened the modem.

rednet.open("right")

shoutBoxes = { }

if fs.exists("shoutBoxes") then
  local shoutBoxesFile = fs.open("shoutBoxes", "r")
  for shoutBox in shoutBoxesFile.readLine do
    table.insert(shoutBoxes, shoutBox)
  end
  shoutBoxesFile.close() 
end
  

function debugTable(table)
  local serialize = textutils.serialize(table)
  print("debugTable: " .. serialize)
end

function getShouts()
  print("getShouts() called!")
  local shouts = {}
  if fs.exists("shouts") then 
    local shoutsFile = fs.open("shouts","r")
    for shout in shoutsFile.readLine do
      table.insert(shouts,shout) 
    end
    shoutsFile.close() 
  else  
    shouts = {"Shout in a shoutBox to leave the first shout"}
  end
  return shouts
end


function sendShouts()
  print("sendShouts()")
  local shouts = getShouts()
  local msg = textutils.serialize(shouts)
  rednet.broadcast(msg)
end

function registerShoutBox(id)
  print("Registering " .. id .. " as a shoutBox")
  local shoutBoxes = {}
  local shoutBoxesFile
  if fs.exists("shoutBoxes") ~= true then
    shoutBoxesFile = fs.open("shoutBoxes","w")
    shoutBoxesFile.writeLine(id)
    shoutBoxesFile.close()
    shoutBoxes = { id }
  else
    shoutBoxesFile = fs.open("shoutBoxes", "r")
      for shoutBox in shoutBoxesFile.readLine do
        table.insert(shoutBoxes, shoutBox)
      end
    shoutBoxesFile.close() 
  end
  
  -- check that id isn't already known
  for i, shoutBox in pairs(shoutBoxes) do
    if id ~= shoutBox then
      table.insert(shoutBoxes, id)
      shoutBoxesFile = fs.open("shoutBoxes", "a")
      shoutBoxesFile.writeLine(id)
      shoutBoxesFile.close()
    end
  end
end

function listener()
  local id, msg, d = rednet.receive()
  msg = tostring(msg)
  shoutAPI.msgLog(id, msg, d)
  
  -- only take a new shout from known shoutBoxes
  for i, shoutBox in pairs(shoutBoxes) do
    --print("--shoutBox check- msg from " .. tostring(id) .. " checking for: " .. tostring(shoutBox))
    if tostring(id) == tostring(shoutBox) then
      --print("--Shoutbox: " ..shoutBox)
      if msg ~= "Register me as a shoutBox Request" then
        -- incoming shout from a shoutBox
        if msg == "clearShouts" then
          --print("calling clearShouts() for: " .. id .."/"..d ..": ".. msg)
          clearShouts()
          sendShouts()
        else
          print("--ID "..id.." is shouting: " ..msg)
          table.insert(getShouts(), msg)
          
          if fs.exists("shouts") ~= true then
            local shoutsFile = fs.open("shouts", "w")
            shoutsFile.writeLine(msg)
            shoutsFile.close()
            sendShouts()
          else
            local shoutsFile = fs.open("shouts", "a")
            shoutsFile.writeLine(msg)
            shoutsFile.close()
            sendShouts()            
          end
        end
      end
    end
  end
  
  if msg == "Update shouts Request" then
    sendShouts()
  end
  if msg == "Router Request" then
    rednet.broadcast("I am your shoutRouter")
  end
  if msg == "Register me as a shoutBox Request" then
    registerShoutBox(tostring(id))
  end
end

function clearShouts()
  if fs.exists("shouts") then 
    print("deleting shouts")
    fs.delete("shouts") 
  end
end

sendShouts()

print("listening for shouts and requests...")
while true do
  listener()
end
