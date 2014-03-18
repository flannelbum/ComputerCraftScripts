-- 0B8MJZ6e

-- cFarmMaster

rednet.open("top")
msgTable = { }
msgQueue = { }


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


function listener()
  -- listen for known commands and fire next step
  id, msg, d = rednet.receive()
  msgLog(id, msg, d)
  
  msgTable = { id = tostring(id), msg = tostring(msg), d = tostring(d), status = "new" }
  -- plop this stuff in the msgTable
  table.insert(msgQueue, msgTable)
  drawDisplay(msgTable)
end

function typedInput()
  -- just waits on user input and broadcasts it.
  input = tostring(read())
  rednet.broadcast(input)
end

function DIKY(id)
  id = tostring(id)
  knownHosts = {"1838", "1839"}
  for i, knownHost in pairs(knownHosts) do
    if id == knownHost then
      return true
    end
  end
  return false
end



function drawDisplay(lastMsg)
  maxX,maxY = term.getSize()

  for i = 1, maxX do
    term.setCursorPos(i,1)
    term.write(" ")
  end
  term.setCursorPos(1,1)
  print("Cactus Farm Master ID: ".. os.getComputerID() .. "\nmax x/y: ".. maxX .. "/" .. maxY)
  -- debugTable(msgQueue)
  
  if lastMsg ~= nil then
    term.setCursorPos(1,maxY-2)
    term.write("ID: "..lastMsg["id"].." MSG: "..lastMsg["msg"].."    ") -- trailing space for display lazyness
  end
  term.setCursorPos(1, maxY-1)
  print("type a broadcast: ")
  term.setCursorPos(1, 19)
end

function processQueue()
  -- Loops through the msgQueue, does stuff for each message, and rebuilds queue for next run.
  newQueue = {}

  -- print("<<<<< input queue:")
  -- debugTable(msgQueue)
  
  
  
  -- start loop to build the new msgQueue
  for i, msg in pairs(msgQueue) do
    -- first stuffs.  Ignore ourselves.
    -- print("msgid = " .. msg.id .. " compid = " ..os.getComputerID())
    if tonumber(msg.id) ~= os.getComputerID() then
      table.insert(newQueue, msg)
    end     
  end
  
  -- print("--afterignore")
  -- debugTable(newQueue)
  msgQueue = newQueue
  newQueue = { }

  
  
  -- now loop through again and:
  --   if I know you, I respond to you with "I know you dude"
  --   if I do not know you, I respond to you with "I don't know you"

  for i, msg in pairs(msgQueue) do
    if DIKY(msg.id) == true then
      rednet.send(tonumber(msg.id), "I know you dude")
    else
      rednet.send(tonumber(msg.id), "I don't know you")
    end
  end
  
  msgQueue = newQueue
  newQueue = { }
  
  
  -- print(">>>>> output queue:")
  -- debugTable(msgQueue)
  
end

term.clear()
drawDisplay()

while true do
  parallel.waitForAny( listener, typedInput )
  processQueue()
end
