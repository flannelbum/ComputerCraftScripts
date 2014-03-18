--name link

if fs.exists("/startup") then
  fs.delete("/startup")
end
 
print("When I grow up, I wanna be a...")
print("1. Chatbot")
print("2. mining turtle")
print("3. dropbox")
local input = tonumber(read())
 
if input ~=nil then
  if input == 1 then
    -- Chatbox
    shell.run("pastebin", "get", "5zhehLyt", "startup")
  elseif input == 2 then
    -- mining turtle
    shell.run("pastebin", "get", "CLtDRNAd", "startup")
  elseif input == 3 then
    -- dropbox fun times
    if fs.exists("dropbox") then
      shell.run("dropbox")
    else
      shell.run("pastebin", "get", "SDZj7NHw", "dropbox")
      shell.run("pastebin", "get", "DdmmvNAA", "dropboxfiles")
      shell.run("dropbox")
      shell.run("dropbox")
    end
  else
    print("I don't know what that means")
  end
end