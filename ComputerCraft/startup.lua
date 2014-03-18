--name startup

term.clear()
version = "v0.07"

--Required APIs: chatAPI
print("loading chatAPI")
if fs.exists("/chatAPI") ~= true then
  print("API not found... attempting get")
  shell.run("pastebin", "get", "n2Wy0Eup", "/chatAPI")
  os.loadAPI("/chatAPI")
else
  print("API Found!")
  os.loadAPI("/chatAPI")
end


print("Opening modem")
chatAPI.openModem()


function listen()
  fromID, msg, dist = rednet.receive()
  print("x"..fromID..": "..msg)
 
  -- Wipe and reboot.  
  if chatAPI.msgchk(fromID, msg, dist) == true then
    print("attempting update")
    if fs.exists("/chatAPI") == true then
      print("deleting chat")
      fs.delete("/chatAPI")
    end
    if fs.exists("/startup") == true then
      print("deleting startup")
      fs.delete("/startup")
    end
    print("attempting get")
    if fs.exists("dropbox") then
      shell.run("dropbox")
      os.reboot()
    else
      shell.run("pastebin", "get", "SDZj7NHw", "dropbox")
      shell.run("pastebin", "get", "DdmmvNAA", "dropboxfiles")
      shell.run("dropbox")
      shell.run("dropbox")
      print("reboot here")
      os.reboot()
    end   
  end
end
 

print("\nTerminal "..version.." chatAPI: "..chatAPI.apiver())
id, aka = chatAPI.whoami()
msg = "I am "..id.." AKA: "..aka
print(msg)
chatAPI.speak(msg)
print("type stuff: ")

while true do
 parallel.waitForAny(listen, chatAPI.speak)
end