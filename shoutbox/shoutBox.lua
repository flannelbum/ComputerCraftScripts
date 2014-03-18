-- shoutBox.lua
-- Registers as a shoutBox to the router.  Accept and send new shouts.

-- assumes the shoutIncludes.lua is loaded as shoutAPI and has already opened the modem.

rednet.broadcast("Register me as a shoutBox Request")

function display(shout)
  term.clear()
  local x,y = term.getSize()
  term.setCursorPos(1,1)
  term.write("ShoutBox -- Type in a new shout and press enter")
  if shout ~= nil then
    term.setCursorPos(1,3)
    term.write("Shouted: " .. shout)
  end
  term.setCursorPos(1,y)
  term.write("shout> ")
end

while true do
  display()
  local shout = tostring(read())
  
  rednet.broadcast(shout)
  display(shout)
  sleep(3)    
end
