-- we5Dk7js
-- pastebin get we5Dk7js startup

-- cFarmFunTesting

function purge()
  for slot = 1, 16 do
    turtle.select(slot)
    turtle.dropDown()
  end
end

function getGas()
  fuelLevel = turtle.getFuelLevel()
  if fuelLevel < 500 then
    turtle.select(1)
    turtle.suck()
    count = turtle.getItemCount(1)
    turtle.drop(count - 1)
    turtle.refuel()
  end
end

function saveZone()
  for steps = 1, 5 do
    turtle.up()
  end
  turtle.turnLeft()
  for steps = 1, 15 do
    turtle.forward()
  end
end

turtle.turnRight()
getGas()
turtle.turnLeft()
saveZone()


