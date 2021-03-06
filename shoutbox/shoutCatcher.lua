-- shoutCatcher.lua
-- Simply catches updates and displays them.  
-- assumes the shoutIncludes.lua is loaded as shoutAPI and has already opened the modem.


--shoutAPI aka shoutIncludes.lua
if fs.exists("shoutIncludes.lua") ~= true then error("shoutIncludes.lua missing.") end
fs.move("shoutIncludes.lua","shoutAPI")
os.loadAPI("shoutAPI")
fs.move("shoutAPI","shoutIncludes.lua")

mon = shoutAPI.getMonitor()
if mon == nil then error("monitor not found.") end

mon.setTextScale(4)
nRate = 5
shoutRouter = 1 --this gets supplied later.

 
rednet.broadcast("Router Request")
rednet.broadcast("Update shouts Request")

function getShouts()
  rednet.broadcast("Update shouts Request")
  if shouts == nil then
    -- if shouts is nil there may not be a router.
    shouts = { "*ERROR* nil shouts: check modem/router distance and conditions" }
  end
  return shouts
end
  

function listener()
  print("listening for shoutRouter: " .. shoutRouter)
  local event, id, msg, d = os.pullEvent("rednet_message")
  shoutAPI.msgLog(id, msg, d)

  if msg == "I am your shoutRouter" then
    shoutRouter = id
  end
 
  if id == shoutRouter and msg ~= "I am your shoutRouter" then
    shouts = textutils.unserialize(msg)
  end
end


function scrollText(tStrings, nRate) -- by toxicwolf.  Thanks, guy!
  -- http://www.computercraft.info/forums2/index.php?/topic/954-monitor-scrolling-text/page__view__findpost__p__7368
  nRate = nRate or 5
  if nRate < 0 then
    error("rate must be positive")
  end
  local nSleep = 1 / nRate
 
  local width, height = mon.getSize()
  local x, y = mon.getCursorPos()
  local sText = ""
  for n = 1, #tStrings do
    sText = sText .. tostring(tStrings[n])
    sText = sText .. " | "
  end

  local nStringRepeat
  local sString = "| "
  if width / string.len(sText) < 1 then
    nStringRepeat = 3
  else
    nStringRepeat = math.ceil(width / string.len(sText) * 3)
  end
  for n = 1, nStringRepeat do
    sString = sString .. sText
  end
 
  while true do
    for n = 1, string.len(sText) do
     local sDisplay = string.sub(sString, n, n + width - 1)
     mon.clearLine()
     mon.setCursorPos(1, y)
     mon.write(sDisplay)
     sleep(nSleep)
    end
  end
end

 
shouts = getShouts()
 
while true do
parallel.waitForAny(listener, function() scrollText(shouts, 5) end)
end