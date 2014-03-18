-- pBUD1T6j

-- Settings:
mon = peripheral.wrap("top")
bundle = "left"
invertOutput = false
fillUnused = true
monX, monY = mon.getSize()


print("flannel's fancy flipping buttons is running!")
print("Max x and y: " .. monX .. ":" .. monY)

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

-- Check for saved buttons and create default if needed
if fs.exists("buttonvars") then
  buttons = load("buttonvars")
else

  --DEFAULT BUTTONS
  --current buttons are 7x3 without border
  buttons = {
      white = {minX = 0, minY = 0, maxX = 0, maxY = 0, color = colors.white, textColor = colors.white, active = false,
              lines = { "","White", ""}},
     orange = {minX = 20, minY = 1 , maxX = 28, maxY = 6 , color = colors.orange, textColor = colors.white, active = false,
              lines = { "","Orange", ""}},
    magenta = {minX = 20, minY = 7 , maxX = 28, maxY = 12, color = colors.magenta, textColor = colors.white, active = false,
              lines = { "","Magenta", ""}},
  lightBlue = {minX = 20 , minY = 13, maxX = 28, maxY = 18, color = colors.lightBlue, textColor = colors.white, active = false,
              lines = { ""," Light ", " Blue  "}},
     yellow = {minX = 11, minY = 13, maxX = 19, maxY = 18, color = colors.yellow, textColor = colors.black, active = false,
              lines = { "","Yellow", ""}},
       lime = {minX = 11, minY = 7 , maxX = 19, maxY = 12, color = colors.lime, textColor = colors.white, active = false,
              lines = { ""," Lime", ""}},
       pink = {minX = 11, minY = 1 , maxX = 19, maxY = 6 , color = colors.pink, textColor = colors.white, active = false,
              lines = { "unused"," Pink", ""}},
  lightGray = {minX = 2 , minY = 7 , maxX = 10, maxY = 12, color = colors.lightGray, textColor = colors.white, active = false,
              lines = { "unused"," Light", " Gray"}},
       gray = {minX = 2 , minY = 13, maxX = 10, maxY = 18, color = colors.gray, textColor = colors.white, active = false,
              lines = { "unused"," Gray", ""}},
       cyan = {minX = 2, minY = 1, maxX = 10, maxY = 6, color = colors.cyan, textColor = colors.white, active = false,
              lines = { "unused"," Cyan", ""}},       
     purple = {minX = 0, minY = 0, maxX = 0, maxY = 0, color = colors.purple, textColor = colors.white, active = false,
              lines = { "","Purple", ""}},
       blue = {minX = 0, minY = 0, maxX = 0, maxY = 0, color = colors.blue, textColor = colors.white, active = false,
              lines = { "","Blue", ""}},
      brown = {minX = 0, minY = 0, maxX = 0, maxY = 0, color = colors.brown, textColor = colors.white, active = false,
              lines = { "","Brown", ""}},
      green = {minX = 0, minY = 0, maxX = 0, maxY = 0, color = colors.green, textColor = colors.white, active = false,
              lines = { "","Green", ""}},
        red = {minX = 0, minY = 0, maxX = 0, maxY = 0, color = colors.red, textColor = colors.white, active = false,
              lines = { "","Green", ""}},
      black = {minX = 0, minY = 0, maxX = 0, maxY = 0, color = colors.black, textColor = colors.white, active = false,
              lines = { "","Black", ""}},
              
  }
  save(buttons, "buttonvars")
end

-- Supporting functions

function setSignal()
  combinedColors = 0
  -- Loop through buttons and combine all colors so we'll only
  -- call setBundledOutput once to set all output.
  for __key, box in pairs(buttons) do
    -- Do inversion check and craft combinded colors.
    if box.active == true and invertOutput == false then
      combinedColors = combinedColors + colors.combine(box.color)
    elseif box.active == false and invertOutput == true then
      combinedColors = combinedColors + colors.combine(box.color)
    end
    
    -- Check if we're to send a signal on unused buttons
    if fillUnused == true then
      if box.minX == 0 and box.maxX == 0 then
        combinedColors = combinedColors + colors.combine(box.color)
      end
    end
  end
  -- Now that we've built the colors, set the output
  rs.setBundledOutput(bundle, combinedColors)
end

function drawBox(minX, minY, maxX, maxY, color, textColor, active, lines)
  x,y = minX,minY
  monX, monY = mon.getSize()
  
  -- Only attempt drawing buttons that have a valid size
  if minX > 0 and maxX < monX and minY > 0 and minY < monY then
  
    -- First, loop through and draw the background, active or not, space by space
    while y <= maxY do
      while x <= maxX do
        mon.setCursorPos(x,y)
        if active == true then
          mon.setBackgroundColor(color)
        else
          if x == minX or x == maxX then
            if y >= minY and y <= maxY then
              -- we are on an x boarder
              mon.setBackgroundColor(color)
            end
          elseif y == minY or y == maxY then
              -- we are on a y boarder
              mon.setBackgroundColor(color)
          else
            mon.setBackgroundColor(colors.black)
          end      
        end
        mon.write(" ")
        x = x + 1 
      end
      x = minX
      y = y + 1  
    end
    
    -- Now draw text on the button
    if active == true then
      mon.setBackgroundColor(color)
      mon.setTextColor(textColor)
      mon.setCursorPos(minX + 3, maxY - 1)
      mon.write("On")
    else
      mon.setBackgroundColor(colors.black)
      mon.setTextColor(color)
      mon.setCursorPos(minX + 3, maxY - 1)
      mon.write("Off")
    end
    for y = 1, #lines do
      mon.setCursorPos(minX + 1, minY + y )
      mon.write(lines[y])
      y = y + 1
    end
  end
end 


function drawDisplay(debugbit)
  mon.setBackgroundColor(colors.black)
  mon.clear()
  -- Loop through buttons and draw each box
  for boxName, box in pairs(buttons) do
    drawBox(box.minX, box.minY, box.maxX, box.maxY, box.color, box.textColor, box.active, box.lines)
  end
  if debugbit == true then
    mon.setCursorPos(1, monY)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.write(monX .. ":" .. monY .. " | Refresh |") 
  end
end

function pressed(xPos, yPos)
  for __key, box in pairs(buttons) do
    if xPos >= box.minX and xPos <= box.maxX then
      if yPos >= box.minY and yPos <= box.maxY then
      -- user pressed in a box.  toggle active and redraw
        if box.active ~= true then
          box.active = true
        else
          box.active = false
        end
        --before redraw/resignal, save button update to a file
        save(buttons, "buttonvars")
        drawDisplay()
        setSignal()
      end
    end
  end
end

-- Print where pressed and draw a reset area that's active
function debugging(xPos, yPos)
  mon.setBackgroundColor(colors.black)
  mon.setTextColor(colors.white)
  mon.setCursorPos(xPos, yPos)
  mon.write(xPos .. ":" ..yPos)
  if xPos >= 8 and xPos <= 16 then
    if yPos == 19 then
      drawDisplay(true)
      setSignal()
    end
  end
end


-- Finally draw our initial display, set the initial output, and wait for monitor_touch
drawDisplay()
setSignal()

while true do
  event, side, xPos, yPos = os.pullEvent("monitor_touch")  
  print(event .. " ===> Side: " .. tostring(side) .. ", " .. "X: " .. tostring(xPos) .. ", " .. "Y: " .. tostring(yPos))
  pressed(xPos, yPos)
  --debugging(xPos, yPos)
end