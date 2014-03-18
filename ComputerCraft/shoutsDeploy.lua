-- gyeLzFk3

-- shoutsDeploy

version = 1.5
firstLine = "--Deployed with shoutsDeploy v" .. tostring(version)

-- clean up any of our previous stuff
rmFileList = {
  "startup"
  ,"startup"
  ,"shoutRoute"
  ,"shoutCatcher"
  ,"shoutBox"
  ,"msgLog"
  ,"shouts"
  ,"shoutBoxes"
  ,"shout"
  ,"shoutDeploy"
}

-- set tables for lines of our different startup files.
shoutDeploy_startup = {firstLine
  ,"-- shoutDeploy startup"
  ,"if fs.exists(\"shoutDeploy\") then fs.delete(\"shoutDeploy\") end"
  ,"shell.run(\"pastebin\",\"get\",\"gyeLzFk3\",\"shoutDeploy\")"
  ,"shell.run(\"shoutDeploy\")"
}

shoutBox_startup = {firstLine
  ,"-- shoutBox startup"
  ,"if fs.exists(\"shoutBox\") then fs.delete(\"shoutBox\") end"
  ,"shell.run(\"pastebin\",\"get\",\"0aVyeB9H\",\"shoutBox\")"
  ,"shell.run(\"shoutBox\")"
}

shoutCatcher_startup = {firstLine
  ,"-- shoutCatcher startup"
  ,"if fs.exists(\"shoutCatcher\") then fs.delete(\"shoutCatcher\") end"
  ,"shell.run(\"pastebin\",\"get\",\"wiFJ6F3y\",\"shoutCatcher\")"
  ,"shell.run(\"shoutCatcher\")"
}          

shoutRoute_startup = {firstLine
  ,"-- shoutRoute startup"
  ,"if fs.exists(\"shoutRoute\") then fs.delete(\"shoutRoute\") end"
  ,"shell.run(\"pastebin\",\"get\",\"yp2gLh0r\",\"shoutRoute\")"
  ,"shell.run(\"shoutRoute\")"
}

menu = { -- What do they type, what startup table, what should this be listed as
   {"1", shoutBox_startup, "[1] shoutBox"}
  ,{"2", shoutCatcher_startup, "[2] shoutCatcher"}
  ,{"3", shoutRoute_startup, "[3] shoutRoute"}
  ,{"4", shoutDeploy_startup, "[4] shoutDeploy"}
}



function rmFile(filename)
  if fs.exists(filename) then 
    print("Deleting: " .. filename)
    fs.delete(filename)
  end
end

function debugTable(table)
  serialize = textutils.serialize(table)
  print("debugTable: " .. serialize)
end

-- top level delete of all known files
for id, file in ipairs(rmFileList) do
  rmFile(file)
end



function makeStartup(startupLines) 
  -- create the startup file and write each table value as a line in the file
  print("Creating startup file...")
  startupFile = fs.open("startup", "w")
  for id, line in ipairs(startupLines) do
    startupFile.writeLine(line)
  end
  startupFile.close()
end


print("writing default startup")
makeStartup(shoutDeploy_startup)


function drawMenu()
  print("")
  for id, menuText in ipairs(menu) do
      print(menuText[3])
  end
  print("")
  print("type a selection: ")
end

function optionCheck(typed)
  for id, option in ipairs(menu) do
    if typed == option[1] then
      return option[2]
    end 
  end
end

drawMenu()
input = tostring(read())

startup = optionCheck(input)
if startup == nil then
  print("invalid option.  quitting.")
else
  makeStartup(startup)
  os.reboot()
end


