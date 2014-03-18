-- 0B8MJZ6e
-- pastebin get 0B8MJZ6e cFarmMember
-- cFarmMember

-- clear the msgLog
if fs.exists("msgLog") then fs.delete("msgLog") end

rednet.open("left")
master = 1948
cardinalNames = { "SOUTH", "WEST", "NORTH", "EAST" }
if os.getComputerLabel() == nil then os.setComputerLabel("Unlabled") end

msgTable = { }
msgQueue = { }

cardinal = 2 -- assumed all turtles are deployed in this orientation "NORTH"

commands = {
  {input = "checkin",
  
    action = function(data, id)
      if os.getComputerID() == master then
        -- if we have an id, we need to record the node
        if id ~= nil then
          nodeInfo = data
          nodeHome = {} -- {x,y,z}
          nodeLocation = {} -- {x,y,z}
          string.gsub(data, "{(.-)}", function(a) table.insert(nodeHome, tonumber(a)) end )
          nodeFuel = nodeHome[#nodeHome]
          table.remove(nodeHome, #nodeHome)
          for i = 1, 3 do 
            table.insert(nodeLocation, nodeHome[4] )
            table.remove(nodeHome, 4 )          
          end
          addNode(id, nodeHome, nodeLocation, nodeFuel)
        else
          -- we are master and with no id we're going to tell turtles to checkin
          rednet.broadcast("checkin")
        end
        
      -- we are a turtle that's seen this message.
      -- only listen to master        
      elseif id == master then
        x,y,z = gps.locate()
        sleep(1)
        rednet.send(master, "checkin "..os.getComputerLabel()..":{"..x.."}{"..y.."}{"..z.."}:{"..turtle.getFuelLevel().."}") 
      end
    end
  }
  ,{input = "Register", 
 
    action = function(data,id)
      if os.getComputerID() == master then
        -- listen for this message and then record the node with checkin assuming it's at commands[1]
        -- then tell the turtle to go home
        if data ~= nill and data ~= "" then
          commands[1].action(data,id)
          rednet.send(id, "goHome")
        end
      elseif os.getComputerID() == id then
        print("Register intended for Deploy only")
      end
    end
  }
  ,{input = "goHome",
 
    action = function(data,id)
      if os.getComputerID() == master and id == nil then
        rednet.broadcast("goHome")
      elseif id == nil or id == master then
        goHome() 
      end
    end
  }
  ,{input = "walk",
  
    action = function(data,id)
      if os.getComputerID() == master and id == nil then
        print("walk command for turtles only")
      elseif os.getComputerID() ~= master then
        if turtle.getFuelLevel() < 1 then
          print("I've not enough fuel!")
        else
          turtle.forward()
          if turtle.down() == true then
            x,y,z = gps.locate()
            label = "{"..x.."}{"..y.."}{"..z.."}"
            print("labeled!")
            os.setComputerLabel(label)
            rednet.send(master, "checkin "..os.getComputerLabel()..":{"..x.."}{"..y.."}{"..z.."}:{"..turtle.getFuelLevel().."}") 
          end
        end
      end
    end
  }
  ,{input = "harvest", 
  
    action = function()
      if os.getComputerID() == master then
        rednet.broadcast("harvest")
      elseif id == nil or id == master then
        move("up", 1)  
      end
    end
  }
  ,{input = "pickup", 
 
    action = function()
      turtle.suck()

      move("forward", 1)
      turtle.suck()
      move("right", 0)
      turtle.suck()

      move("forward", 1)
      move("right", 0)
      turtle.suck()

      move("forward", 1)
      turtle.suck()

      move("forward", 1)
      move("right", 0)
      turtle.suck()

      move("forward", 1)
      turtle.suck()

      move("forward", 1)
      move("right", 0)
      turtle.suck()

      move("forward", 1)
      turtle.suck()

      move("right", 1)
      move("left", 0)
    end
   }
  ,{input = "plant", 
    
    action = function()
      move("up", 1)
      move("forward", 1)
      turtle.placeDown()
      
      move("back", 2)
      turtle.placeDown()
      
      move("right", 1)
      move("right", 1)
      turtle.placeDown()
      
      move("right", 2)
      turtle.placeDown()
      
      move("left", 0)
      
      safeplane = -2146
      x,y,z = gps.locate()
      steps = math.abs(z) - math.abs(safeplane)
      move("forward", steps)
      move("down", 4)
      move("back", steps)
      move("right", 1)
      move("right", 0)
      move("up", 2)
    end
  }  
  ,{input = "refuel",
  
    action = function()
      if os.getComputerID() == master then
        rednet.broadcast()
      else
      end
      turtle.select(1)
      turtle.suck()
      turtle.refuel()
    end
  }
  ,{input = "update",
    
    action = function(data,id)
      if os.getComputerID() == master and id == nil then
        -- we are the master computer.  we generate and send the file
        file = fs.open("cFarmMember","r")
        data = file.readAll()
        file.close()
        rednet.broadcast("update "..data)
      else
        -- we are a turtle.  we need to create the file from the data
        if data == nil or data == "" then 
          print("data for update is nill.  nothing to do.")
        elseif os.getComputerID() ~= master and id == master then
          file = fs.open("cFarmMember","w")
          file.write(data)
          file.close()
          print("cFarmMember file written")
          os.reboot()
        end
      end
    end
  }
  ,{input = "move",
    
    action = function(data,id)
      if os.getComputerID() == master and id == nil then
        rednet.broadcast("move "..data)
      elseif os.getComputerID() ~= master then
        msgTable = {}
        for w in string.gmatch(data, "([^%s]+)") do
          table.insert(msgTable, w)
        end     
        if msgTable[1] == nil or msgTable[2] == nil then
          print("Poorly formed move command.  Expecting direction and steps")
        else
          move(msgTable[1], tonumber(msgTable[2]))
        end
      end
    end
  }
  ,{input = "node",
  
    action = function(data)
      if os.getComputerID() ~= master then
        print("node command doesn't work from a node")
      else
        _x,x = string.find(data, " ") -- this should return _x as 1 but it doesn't in code for some reason.
        -- adjust the return ... we're always 6 too many
        _x = _x - 6
        x = x - 6
        rednet.send(tonumber(string.sub(data, 1, x)), string.sub(data, (x+2)))
    end  
  end
  }
  ,{input = "goto",
  
    action = function(data)
      if os.getComputerID() == master then
        print("goto used from turtles only")
      else
        _x,x = string.find(data, " ") -- this should return _x as 1 but it doesn't in code for some reason.
        -- adjust the return ... we're always 6 too many
        _x = _x - 6
        x = x - 6
        navigate(getCoords(data))
      end
    end
  }
  ,{input = "nodes",
    
    action = function()
      -- this is intended to give a dashboard view on the master only
      if os.getComputerID() == master then
        if fs.exists("nodes") then nodes = load("nodes") else nodes = {} end
        print("Currently there are "..#nodes.." registered nodes")
        --debugTable(nodes)
        for i, node in pairs(nodes) do
          if leastFuel == nil then leastFuel = {node.id, node.fuel, node.location[1], node.location[2], node.location[3]} end
          if node.fuel < leastFuel[2] then
            leastFuel[1] = node.id
            leastFuel[2] = node.fuel
            leastFuel[3] = node.location[1]
            leastFuel[4] = node.location[2]
            leastFuel[5] = node.location[3]
          end
          print(node.id..":"..coordName(node.home).." Fuel = "..node.fuel)
        end
        print("Currently there are "..#nodes.." registered nodes")
        print("WARN! Fuel: "..leastFuel[2].." ID: "..leastFuel[1].."  "..leastFuel[3].." "..leastFuel[4].." "..leastFuel[5])
        print("\n")    
      else
        print("nodes command for use on master only")
      end
    end
  }
} 

--[[ autoRefresh BEGIN ]]--
if true == true then  -- only doing this so all of this will collaps in np++


turtle_startup = {
   "-- AutoGenerated startup for turtles"
  ,"shell.run(\"cFarmMember\")"
}
master_startup = {
  "--AutoGenerated startup for the master computer"
  ,"if fs.exists(\"cFarmMember\") then fs.delete(\"cFarmMember\") end"
  ,"shell.run(\"pastebin\", \"get\", \"0B8MJZ6e\", \"cFarmMember\")"
  ,"shell.run(\"cFarmMember\")"
}


function makeStartup(startupLines) 
  -- create the startup file and write each table value as a line in the file
  print("Creating startup file...")
  startupFile = fs.open("startup", "w")
  for id, line in ipairs(startupLines) do
    startupFile.writeLine(line)
  end
  startupFile.close()
end

function rmFile(filename)
  if fs.exists(filename) then 
    print("Deleting: " .. filename)
    fs.delete(filename)
  end
end

if os.getComputerID() == master then
  rmFile("startup")
  makeStartup(master_startup)
else
  rmFile("startup")
  makeStartup(turtle_startup)
end


end
--[[ autoRefresh END ]]--

--[[ Generic helper functions BEGIN ]]--
if true == true then
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

function debugTable(table)
  serialize = textutils.serialize(table)
  print("debugTable: " .. serialize)
end

function msgLog(id, msg, d)
  data = "ID:" .. id .. " MSG: " .. msg .." d:" .. d
  logfile = fs.open("msgLog", "a")
  logfile.writeLine(data)
  logfile.close()
end

function drawDisplay(lastMsg)
  maxX,maxY = term.getSize()

  for i = 1, maxX do
    term.setCursorPos(i,1)
    term.write(" ")
    term.setCursorPos(i,2)
    term.write(" ")
  end
  term.setCursorPos(1,1)
  term.write("Name: "..os.getComputerLabel())
  term.write("ID: ".. os.getComputerID())

  
  if lastMsg ~= nil then
    term.setCursorPos(1,maxY-2)
    term.write("ID: "..lastMsg["id"].." MSG: "..lastMsg["msg"].."    ") -- trailing space for display lazyness
  end
  term.setCursorPos(1, maxY-1)
  term.write("type a broadcast:                                          ")
  term.setCursorPos(1, maxY)
end

function DIKY(id)
  --if nodes == nil then nodes = load("nodes") end
  if fs.exists("nodes") then nodes = load("nodes") else nodes = {} end
  if nodes == nil then return false end
  for i, node in pairs(nodes) do
    if id == node.id then
      return true
    end
  end
  return false
end

function addNode(nodeID, nodeHome, nodeLocation, nodeFuel)

  -- Adds a node to the master's nodes file or updates it with the node info
  if fs.exists("nodes") then nodes = load("nodes") else nodes = {} end
  
  -- check for existing and update with new info
  knownNodeFlag = false
  for i, node in pairs(nodes) do
    if coordName(nodeHome) == coordName(node.home) then
      --node exists, update its info  
      --##May need to consider decomissioning here
      nodes[i].id = nodeID
      nodes[i].location = nodeLocation
      nodes[i].fuel = nodeFuel
      knownNodeFlag = true
    end
  end
  if knownNodeFlag == false then
    newNode = {id = nodeID, home = nodeHome, location = nodeLocation, fuel = nodeFuel}
    table.insert(nodes, newNode)
  end
  --debugTable(nodes)
  save(nodes, "nodes")
end

end -- end is for the helper function collapse
--[[Generic helper functions END]]--

--[[ Navigation Functions BEGIN ]]--
if true == true then
function getFriendlyCardinal(cardinal)
  if cardinal == nil then return "Unknown.. nill cardinal passed" end
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

function getCoords(xyzString)
  -- expects xyzString like "4 11 12" and returns 4, 11, 12 as numbers.
  if #xyzString < 6 or xyzString == nil then return false end
  xyzTab = {}
  
  string.gsub(xyzString, "([^%s]+)", function(a) table.insert(xyzTab, tonumber(a)) end )
  
  if #xyzTab < 3 or xyzTab == nil then return false end
  return tonumber(xyzTab[1]), tonumber(xyzTab[2]), tonumber(xyzTab[3])
end

function move(direction, steps)
print("move("..direction..", "..steps..")")
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
    for i = 1, steps, 1 do
      turtle.forward()
    end
  else
    --dont' spam the world with your tiny problems.
    --rednet.broadcast("can't move?")
    print("can't move!!\n\n")
  end
  
  -- x,y,z = gps.locate()
  -- rednet.send(master, "lastLocation "..x.." "..y.." "..z)
  return x,y,z
end

function navigate(x,y,z)
  print("navigate("..x..", "..y..", "..z..")")
  -- revise to make this more deterministic
  cx,cy,cz = gps.locate()
  print("current( "..cx..", "..cy..", "..cz..")")
  
  
  if cy > y then
    move("down", math.abs(cy - y))
  elseif cy < y then
    move("up", math.abs(cy - y))
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

function coordName(coordsTable)
  --returns string of coords supplied in cordsTable
  --expecting coordsTable = { x, y, z }
  name = ""
  for i, coord in pairs(coordsTable) do
    name = name.."{"..tostring(coord).."}"
  end
  return name  
end

function goHome()    
    --Your home address is your name.
    home = {} -- {x,y,z}
    string.gsub(os.getComputerLabel(), "{(.-)}", function(a) table.insert(home, tonumber(a)) end )
    navigate(home[1], (home[2]-2), home[3])
    move("up",2)
    faceDirection("NORTH")    
end


end -- end navigation functions
--[[ Navigation functions EEND ]]--



function processQueue()
  --[[   
  processQueue()
  Loops through the msgQueue, does stuff for each message, and rebuilds queue for next run.
  
  for reference, this is the structure of the msgQueue table:
  msgQueue = { id = tonumber(id), msg = tostring(msg), d = tostring(d), status = "new" }
  --]]
  
  newQueue = {}
    
  -- cleanup dones
  for i, msg in pairs(msgQueue) do
    if msg.status ~= "done" then
      table.insert(newQueue, msg)   
    end  
  end
  msgQueue = newQueue
  newQueue = { }
  -- ignore ourselves
  for i, msg in pairs(msgQueue) do 
    if msg.id ~= os.getComputerID() then
      table.insert(newQueue, msg)
    end  
  end
  msgQueue = newQueue
  newQueue = { }

  -- handle all messages we have a command defined for at the top.
  for i, msg in pairs(msgQueue) do
    if string.find(msg.msg, " ") == nil then
      -- our cmd is our full message.. there were no vars.
      cmd = msg.msg
    else
      cmd = string.sub(msg.msg, 1, string.find(msg.msg, " ") - 1)
    end
    for k, command in pairs(commands) do
      if cmd == command.input then
        msg.status = "done"
        -- pass in everything after our command and a space. 
        command.action(string.sub(msg.msg, #command.input + 2),msg.id)
      end
    end
  end
   
  --catch all messages we're not handling in the message log.
  for i, msg in pairs(msgQueue) do
    if msg.status == "new" then
      msg.status = "done"
      print("Dropping Message!\nFrom: "..msg.id.."\nmsg: "..msg.msg.."\n\n")
      msgLog(msg.id, msg.msg, msg.d)
    end
  end
end



term.clear()
drawDisplay()

function listener()
  -- listen/record all rednet, redraw display.
  id, msg, d = rednet.receive()  
  --msgLog(id,msg,d)
  msgTable = { id = tonumber(id), msg = tostring(msg), d = tostring(d), status = "new" }
  
  if id == 65534 then 
    -- gps responce. totally ignoring.
  else
    table.insert(msgQueue, msgTable)
    drawDisplay(msgTable)
  end
end



function typedInput()
  cmdFound = false
  -- just waits on user input and broadcasts it.
  input = tostring(read())
  
  -- check input against known commands and do action OR just broadcast the message.
  if string.find(input, " ") == nil then
    -- our cmd is our full message.. there were no vars.
    cmd = input
  else
    cmd = string.sub(input, 1, string.find(input, " ") - 1)
  end
  for k, command in pairs(commands) do
    if cmd == command.input then
      cmdFound = true
      -- pass in everything after our command and a space. 
      command.action(string.sub(input, #command.input + 2))
    end
  end
  if cmdFound == false then 
    print("BROADCASTING!!!!\n\n")
    rednet.broadcast(input) 
  end
end




while true do
  parallel.waitForAny( listener, typedInput )
  processQueue() -- processes all rednet we got from listener()
end


