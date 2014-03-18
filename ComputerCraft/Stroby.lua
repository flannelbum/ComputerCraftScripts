-- bCQ5pYc4

-- pastebin get bCQ5pYc4 s

-- Stroby
-- randomly select a side to output a redstone signal
-- output the signal and clear all other signals before 
-- outputting again


if os.getComputerLabel() == nil then os.setComputerLabel("Stroby") end

sides = {"left", "right", "top", "bottom", "front", "back"}

function getSide(number)
  -- returns side and "front" if nil
  if sides[number] == nil then
    return "front"
  else
    return sides[number]
  end  
end

function clearOutput()
  for i, side in pairs(sides) do
    rs.setOutput(side, false)
  end
end

while true do
  clearOutput()
  for i=1, 2 do
    key = math.random(1,6)
    rs.setOutput(getSide(key), true)
  end
  sleep(1)
end