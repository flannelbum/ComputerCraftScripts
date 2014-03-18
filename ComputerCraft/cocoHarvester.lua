-- N0iXQc9E
-- pastebin get N0iXQc9E startup
-- Turtle-powered coco harvester.  
 
--[[
 
  By default, turtle expects to be one block away from the first tree and facing that tree.
  The tree should be 10 tall and have another tree 4 blocks to the left of the tree placed in front
  of the turtle.
 
  Crappy diagram to further confuse you:
            Tree
            b
            b
            b
   turtle b Tree
 
  + Ensure seeds are in slot 1 (the first slot)
  + Put any fuel in slot 16 (the last slot)
  + Ensure the turtle is fueled!  Check fuel values (lava cell is best)
    http://computercraft.info/wiki/Turtle.refuel
 
]]--
 
digplace = true  -- set to false in order to not break or place anything.. just watch the pathing.
 
 
function speak(msg)
  -- checks fuel and displays that with whatever msg was passed in
  
  turtle.select(16)
  turtle.refuel()
  fuel = turtle.getFuelLevel()
  if fuel < 100 then
    print("<< LOW FUEL!! >>")
  end
  if msg == nil then
    print("[F:"..fuel.."] nevermind.")
  end
    print("[F:"..fuel.."] "..msg)
end
 
 
function forward(steps)
  -- keeps us from having to type turtle.forward() a bunch of times.
  
  if steps ~= nil then
    for i = 1, steps do
      turtle.forward()
    end
  else
    speak("forward? why for?")
  end
end
 
 
function digPlace(direction, height)
  -- if digplace is set true, we'll actually dig and place.. otherwise, we'll just move
  
  for step = 1, height do
    if direction == "up" then
      -- going up, we do that after digging
      if digplace == true then
        turtle.dig()
        turtle.place()
      end
      turtle.up()
    elseif direction == "down" then
      -- going down, we do that after moving
      turtle.down()
      if digplace == true then
        turtle.dig()
        turtle.place()
      end      
    else
      print("I don't understand direction")
    end
  end
end
 
 
function updown()
  -- harvests two sides of a tree after seed check.

  turtle.select(1)
  if turtle.getItemCount(1) < 1 then
    speak("Going commando cause I got NO SEEDS!!")
    print("\n<< sleeping for 120 seconds... >>\nUse CTRL-T to terminate and add some seeds\nSeeds go in slot 16... the last slot\nRestart when filled")
    sleep(120)
  end

  -- do stuff for up a tree
  digPlace("up",10)

  -- move to go down a tree
  forward(4)
  turtle.turnRight()
  turtle.turnRight()

  -- do stuff for down the tree
  digPlace("down",10)

end
 
 
function harvest()
  -- Below is total turtle movements.  

  updown() --go up and down a tree
  turtle.turnLeft() -- start moving to the next tree side
  forward(2)
  turtle.turnRight()
  forward(2)
  turtle.turnRight() 
  updown() -- now at other treeside, go up and down the tree
  turtle.turnRight() --we're in the middle, turn around to the other tree
  turtle.turnRight()
  updown() -- get the sides of the tree and...
  turtle.turnLeft()
  forward(2)
  turtle.turnRight()
  forward(2)
  turtle.turnRight()
  updown()
  turtle.turnRight()
  forward(4) -- ... we're home.
  turtle.turnLeft() -- so, face the tree and get ready to do it again.
end


-- initial display
term.clear()
term.setCursorPos(1,1)
speak("Push the button!!")

-- main loop
while true do
  os.pullEvent("redstone")  -- wait for a redstone signal
  if rs.getInput("back") == true then
    speak("Harvesting")
    harvest()
    speak("Radical!")
    speak("Push the button!!")
  end
end