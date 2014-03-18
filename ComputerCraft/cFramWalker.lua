-- 8quTFGAY

-- pastebin get 8quTFGAY w

-- cFarmWalker
-- find holes, generate name, save name and coords to file


rednet.open("left")

-- supporting function for table saving to and loading from file
function save(table, name)
  file = fs.open(name, "w")
  file.write(textutils.serialize(table))
  file.close()
end
function load(name)
  file = fs.open(name, "r")
  data = file.readAll()
  file.close()
  return textutils.unserialize(data)
end

function nodeCheck(x,y,z)
-- returns true/false if we've already recorded this node.  
  if fs.exists("nodes") then nodes = load("nodes") else nodes = {} end
  if #nodes > 0 then
    for i, node in ipairs(nodes) do
      if node.x == x and node.y == y and node.z == z then
        return true
      else
        return false
      end
    end
  else
    return false
  end
end
  
function addNodeHome(x,y,z)
  if nodeCheck(x,y,z) == false then
    name = "{"..tostring(x).."}{"..tostring(y).."}{"..tostring(z).."}"   
    print("+ "..name)
    table.insert(nodes, {name,x,y,z})
    save(nodes,"nodes")
  end
  slotCount = slotCount + 1
end

function checkPOS()
-- returns if we hit a wall, coords, and what wall we hit if we hit one
  x,y,z = gps.locate()
  if z == -2146 then
    return true,x,y,z,"south"
  elseif x == -1743 then 
    return true,x,y,z,"west"
  elseif z == -2175 then
    return true,x,y,z,"north"
  elseif x == -1715 then
    return true,x,y,z,"east"
  else
    return false,x,y,z
  end
end

function handleWall(wall)
-- "jesus take the wheel" for when we hit a wall
  if wall == "west" then 
    turtle.turnRight() 
    turtle.forward()
    turtle.forward()
    turtle.turnRight()
    turtle.forward()
  elseif wall == "east" then
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.turnLeft()
    turtle.forward()
  elseif wall == "north" or wall == "south" then
    return "done"
  end
end


-- main loop

slotCount = 0

while slotCount <= 97 do
  
  onWall,x,y,z,wall = checkPOS()

  if onWall == true then
    if handleWall(wall) == "done" then
      print("done")
      break 
    end    
  else
    if turtle.down() == true then
      addNodeHome(x,y-1,z)
      turtle.up()
    end
    turtle.forward()
  end
end