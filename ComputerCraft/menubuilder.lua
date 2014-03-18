-- aJ9KbiL6

mon = peripheral.wrap("left")
scale = .5
mon.setTextScale(scale)
defaultBackgroundColor = colors.black
defaultTextColor = colors.white
mon.setBackgroundColor(defaultBackgroundColor)
mon.setTextColor(defaultTextColor)
mon.clear()

screenX, screenY = mon.getSize()
strXY = screenX .. "/" .. screenY
dots = true

-- Functions to save a table to a file
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

-- Check for saved boxes and create default if needed
if fs.exists("boxvars") then
  boxes = load("boxvars")
else
  boxes = {
     screenP = {minX = 1, minY = screenY, maxX = 3, maxY = screenY, mainColor = colors.green, altColor = colors.gray, textColor = colors.lightGray, active = false, show = true, main = true, background = false, action = "screenPlus",
              lines = { "+ /" }},
     screenM = {minX = 4, minY = screenY, maxX = 5, maxY = screenY, mainColor = colors.green, altColor = colors.gray, textColor = colors.lightGray, active = false, show = true, main = true, background = false, action = "screenMinus",
              lines = { " -" }}, 
     refresh = {minX = 7, minY = screenY, maxX = 7, maxY = screenY, mainColor = colors.red, altColor = colors.gray, textColor = colors.lightGray, active = false, show = true, main = true, background = false, action = "refresh",
              lines = { "R" }},     
      dots = {minX = 8, minY = screenY, maxX = 8, maxY = screenY, mainColor = colors.red, altColor = colors.gray, textColor = colors.lightGray, active = false, show = true, main = true, background = false, action = "toggleDots",
              lines = { "D" }},
      create = {minX = 9, minY = screenY, maxX = 9, maxY = screenY, mainColor = colors.red, altColor = colors.orange, textColor = colors.lightGray, active = false, show = true, main = true, background = false, action = "create",
              lines = { "C" }},
         res = {minX = screenX - (string.len(strXY) - 1), minY = screenY, maxX = screenX, maxY = screenY, mainColor = colors.gray, altColor = colors.gray, textColor = colors.lightGray, active = false, show = true, main = true, background = false, action = "none",
              lines = { strXY }},                
         mbg = {minX = 1, minY = screenY - 2, maxX = screenX, maxY = screenY, mainColor = colors.gray, altColor = colors.gray, textColor = colors.lightGray, active = false, show = true, main = true, background = true, action = "none",
              lines = { "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" }}
  }
end

function drawBox(minX, minY, maxX, maxY, mainColor, textColor, lines)
  --print("drawBox()")
  --print(minX .." ".. minY .." : ".. maxX .." ".. maxY .." : ".. mainColor .." ".. textColor .." ".. lines[1])

  -- draw a solid box
  
  -- flip variables if we got them in a wierd order.  
  if maxX < minX then
    maxX, minX = minX, maxX
  elseif maxY < minY then
    maxY, minY = minY, maxY
  end
  -- gotta redirect the term to the monitor to use paintutils
  term.redirect(mon)
  -- for each horrizontal space draw a verticle line
  i = minX  
  while i <= maxX do
    paintutils.drawLine(i, minY, i, maxY, mainColor)
    i = i + 1
  end
  -- fix the term back
  term.restore()
  -- Draw the box text lines
  i = 1
  while i < #lines + 1 do
    mon.setTextColor(textColor)
    mon.setCursorPos(minX, minY + (i - 1))
    mon.write(lines[i])
    i = i + 1
  end
end

function createBox()
  print("Action is createBox()")
  
  -- indicate that we're creating a box
  drawBox(boxes.create.minX, boxes.create.minY, boxes.create.maxX, boxes.create.maxY, boxes.create.altColor, boxes.create.textColor, { "C" })
  print(boxes.create.minX .." " .. boxes.create.minY .." : " .. boxes.create.maxX .." " .. boxes.create.maxY .. " : " .. boxes.create.altColor .. " " .. boxes.create.textColor)
  
  color = colors.yellow
  mon.setBackgroundColor(color)
  mon.setTextColor(color)
  
  print("Waiting for first touch")
   
  event, side, xPos1, yPos1 = os.pullEvent("monitor_touch")
  mon.setCursorPos(xPos1, yPos1)
  mon.write(" ")
  
  print("waiting on second touch")
  
  event, side, xPos2, yPos2 = os.pullEvent("monitor_touch")
  mon.setCursorPos(xPos1, yPos1)
  mon.write(" ")
  drawBox(xPos1, yPos1, xPos2, yPos2, colors.gray, colors.red, { "Type in", "computer!" ,"Waiting" })
  
  term.clear()
  term.setCursorPos(1,1)
  print("Type in line text\nEach line can safely hold: ".. xPos2 - xPos1 .."x".. yPos2 - yPos1 .." chars.  Blank line exits.  Use a period to put a blank line on a box.")
  i = 1
  lines = {}
  lineLengthActual = ""
  for l = 1, xPos2 - xPos1 do
    lineLengthActual = lineLengthActual .. "-"
  end
  print(lineLengthActual)
  while true do
    print(i .."/".. yPos2 - yPos1 .. ":")
    line = read()
    if line == "" then
      break
    elseif line == "." then
      table.insert(lines, "")
    else
      table.insert(lines, line)
    end
    i = i + 1
  end
  print("Check the screen to see if you like it")
  drawBox(xPos1, yPos1, xPos2, yPos2, colors.gray, colors.red, lines)
  
  -- give color options for main and alt and text.
  -- Give action options
  -- impliment save
  
  
  print("done with creation")
end

function pressed(xPos, yPos)
  -- check if user clicked in displayed box
  for __key, box in pairs(boxes) do
    if box.show == true and box.background == false and box.action ~= "none" then
      if xPos >= box.minX and xPos <= box.maxX then
        if yPos >= box.minY and yPos <= box.maxY then
          -- user pressed in a box.  toggle active and redraw
          return box.action
          -- !! before redraw/resignal, save button update to a file
        end
      end
    end
  end
end

function refresh()
  print("refresh()")
  mon.setTextScale(scale)
  mon.setBackgroundColor(defaultBackgroundColor)
  mon.setTextColor(defaultTextColor)
  mon.clear()
  screenX, screenY = mon.getSize()
  
  -- fix our bottom menue by stuffing back in screenY for min and max y
  -- also resets the strXY string for res box
  strXY = screenX .. "/" .. screenY
  for index, box in pairs(boxes) do
    if box.main == true then
      box.minY, box.maxY = screenY, screenY    
    end
    if box == boxes.res then
      box.lines = { strXY }
      box.minX = screenX - (string.len(strXY) - 1)
    end
    if box == boxes.mbg then
      box.minX = 1
      box.minY = screenY - 1
      box.maxX = screenX + 1
      box.maxY = screenY
    end
  end
  
  -- print("refresh done")
end

function drawScreen()
  print("drawScreen()")
  refresh()
  
  if dots == true then 
    -- dot up the joint
    for y = 1, screenY, 1 do
      for x = 1, screenX, 1 do
        mon.setCursorPos(x,y)
        mon.setBackgroundColor(defaultBackgroundColor)
        mon.setTextColor(defaultTextColor)
        mon.write(".")
      end  
    end
  end
  
  --Loop through boxes and draw them
  -- Draw backgrounds only first
  for index, box in pairs(boxes) do
    if box.show == true and box.background == true or box.action == "none" then
      drawBox(box.minX, box.minY, box.maxX, box.maxY, box.mainColor, box.textColor, box.lines)
    end  
  end
  -- Now draw action boxes
  for index, box in pairs(boxes) do  
    if box.show == true and box.background == false then
      drawBox(box.minX, box.minY, box.maxX, box.maxY, box.mainColor, box.textColor, box.lines)
    end
  end
  
end


-- A good place (mostly) to right the Actions for boxes.

function toggleDots()
  print("Action is toggleDots()")
  if dots == true then 
    dots = false
  else
    dots = true
  end
  print(dots)
  drawScreen()
end

function screenPlus()
  print("Action is screenPlus()")
  scale = scale + .5
  if scale > 5 then scale = 5 end
  mon.setTextScale(scale)
  drawScreen()
end

function screenMinus()
  print("Action is screenMinus()")
  scale = scale - .5
  if scale < .5 then scale = .5 end
  mon.setTextScale(scale)
  drawScreen()
end

function debugTable(table)
  serialize = textutils.serialize(table)
  print("debugTable: " .. serialize)
end



-- [[ MAIN ]] --
drawScreen()

while true do 
  --debugTable(boxes)
  event, side, xPos, yPos = os.pullEvent("monitor_touch")
  action = pressed(xPos, yPos)
  if action ~= nil then
    if action == "refresh" then
      refresh()
      drawScreen()
    elseif action == "create" then
      createBox()
    elseif action == "screenPlus" then
      screenPlus()
    elseif action == "screenMinus" then
      screenMinus()
    elseif action == "toggleDots" then
      toggleDots()
    end
  end
end