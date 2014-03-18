-- we5Dk7js
-- pastebin get we5Dk7js startup

-- cFarmNodeDeploy

cardinal = 0 -- This is south. the grid is behind us.
lowerTerminal = 2103
master = 1948
cardinalNames = { "SOUTH", "WEST", "NORTH", "EAST" }

-- supporting function for table saving to and loading from file
function save(table, name)
  file = fs.open(name, "w")
  file.write(textutils.serialize(table))
  file.close()
  print("saved nodes")
end
function load(name)
  file = fs.open(name, "r")
  data = file.readAll()
  file.close()
  return textutils.unserialize(data)
end

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
    turtle.drop(count - 2)
    turtle.refuel()
  end
end

function move(direction, steps)
  if direction == "forward" then
    for i = 1, steps, 1 do
      turtle.forward()
    end
  elseif direction == "up" then
    for i = 1, steps, 1 do
      turtle.up()
    end
  elseif direction == "left" then
    -- because we're turning left, adjust the cardinal (-) and turn
    cardinal = cardinal - 1
    if cardinal < 0 then cardinal = 3 end
    turtle.turnLeft()
    for i = 1, steps, 1 do
      turtle.forward()
    end
  elseif direction == "right" then
    -- because we're turning right, adjust the cardinal (+) and turn
    cardinal = cardinal + 1
    if cardinal > 3 then cardinal = 0 end
    turtle.turnRight()
    for i = 1, steps, 1 do
      turtle.forward()
    end
  elseif direction == "down" then
    for i = 1, steps, 1 do
      turtle.down()
    end
  elseif direction == "back" then
    move("right", 0)
    move("right", 0)
    -- turtle.turnRight()
    -- turtle.turnRight()
    for i = 1, steps, 1 do
      turtle.forward()
    end
  else
    rednet.broadcast("can't move?")
  end
end

function faceDirection(friendlyName)
   for key, name in pairs(cardinalNames) do
    if name == friendlyName then
      -- currently facing cardinal.  key-1 = the friendly name cardinal
      while cardinal ~= (key - 1) do
        move("right",0)
      end
    end
  end
end

function navigate(x,y,z)
  -- maybe force us facing a specific direction?
  cx,cy,cz = gps.locate()
  
  -- move y
  if cy ~= y then 
    if cy > y then
      move("down", math.abs(cy - y))
    else
      move("up", math.abs(cy - y))
    end
  end
  
  -- move x
  if cx ~= x then
    if cx > x then
      --turn left from north
      faceDirection("WEST")
    else
      --turn right from north
      faceDirection("EAST")
    end
    move("forward", math.abs(cx - x))
  end
  
  -- move z
  if cz ~= z then
    if cz > z then
      --move north
      faceDirection("NORTH")
    else
      --move south
      faceDirection("SOUTH")
    end
    move("forward", math.abs(cz - z))
  end
end

function toStagingArea()
  -- move("up",5)
  -- move("left",15)
  -- move("left",0)
  navigate(-1724, 19, -2142)
  move("left",0) -- to face north without doing a faggy spin
  --move("down",6)
  --faceDirection("NORTH")
end

function getFriendlyCardinal(cardinal)
  if cardinal == nil then return "Unknown.. nill cardinal passed" end
  cardinalNames = { "SOUTH", "WEST", "NORTH", "EAST" }
  if cardinal >= 0 and cardinal <= 3 then
    for key, name in pairs(cardinalNames) do  
      if (key - 1) == cardinal then 
        return name 
      end
    end
  else
    return "Unknown"
  end
end

function setName()
  if os.getComputerID() ~= lowerTerminal then
    nodes = load("/disk/nodes")
    if nodes == nil then
      print("there are no nodes to deploy")
    else
      os.setComputerLabel(nodes[1][1])
      table.remove(nodes, 1)
      print(os.getComputerLabel().." --  "..#nodes.." nodes left")
      save(nodes, "/disk/nodes")
    end
  end
end

function getProgramming()
  fs.copy("/disk/cFarmMember", "/cFarmMember")
end

function main()
  if os.getComputerID() ~= lowerTerminal then
    setName()
    faceDirection("WEST")
    getGas()
    getProgramming()
    toStagingArea()
    x,y,z = gps.locate()
    
    print("Currently: "..x.." "..y.." "..z.."\nFacing: "..cardinal.." AKA: "..getFriendlyCardinal(cardinal))
    
    rednet.open("left")
    rednet.send(master, "Register "..os.getComputerLabel()..":{"..x.."}{"..y.."}{"..z.."}:{"..turtle.getFuelLevel().."}") 
    shell.run("cFarmMember")
    --os.reboot()
  else
    term.clear()
    term.setCursorPos(1,1)
    if fs.exists("/disk/nodes") == true then 
      nodes = load("/disk/nodes")
      print("nodes file present with " .. #nodes .. " nodes to deploy")
      print("Place turtles above to continue deployments")
    else
      print("nodes file missing.")
    end
  end
end

main()

