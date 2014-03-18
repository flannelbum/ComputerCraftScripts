--name mobiAPI

--mobiAPI
function apiver()
  APIversion = "v0.01"
  return APIversion
end

-- program turtle handle commands.
-- who is my master?
-- what am I doing?
-- GPS?  (maybe but not now)

function move(direction, steps)
  if direction == "forward" then
    for i = 1, steps, 1 do
      turtle.forward()
    end
  if direction == "up" then
    for i = 1, steps, 1 do
      turtle.up()
    end
  elseif direction == "left" then
    turtle.turnLeft()
    for i = 1, steps, 1 do
      turtle.forward()
    end
  elseif direction == "right" then
    turtle.turnRight()
    for i = 1, steps, 1 do
      turtle.forward()
    end
  elseif direction == "down" then
    for i = 1, steps, 1 do
      turtle.down()
    end
  elseif direction == "back" then
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, steps, 1 do
      turtle.forward()
    end
  else
    chat.speak("can't move?")
  end
end