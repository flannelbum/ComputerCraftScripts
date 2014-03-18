-- 0aVyeB9H

-- shoutBox
-- Registers as a shoutBox to the router.  Accept and send new shouts.

rednet.open("right")

rednet.broadcast("Register me as a shoutBox Request")

function display(shout)
  term.clear()
  x,y = term.getSize()
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
  shout = tostring(read())
  
  rednet.broadcast(shout)
  display(shout)
  sleep(3)    
end
