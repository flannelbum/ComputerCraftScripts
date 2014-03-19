-- shoutDeploy.lua ..  deploys units in the shoutbox project
-- some parts here are heavily stolen from: https://raw.github.com/Yevano/swarm-api

-- pastebin get 5DDbea5A deploy

local args = { ... }

local url = "https://raw.github.com/flannelbum/ComputerCraftScripts/master/shoutbox/"

local file_list = {
    -- first file is burned into the startup
    shoutBox = {
        "shoutBox.lua"
        ,"shoutIncludes.lua"
    },
    shoutCatcher = {
        "shoutCatcher.lua"
        ,"shoutIncludes.lua"
    },
    shoutRoute = {
        "shoutRoute.lua"
        ,"shoutIncludes.lua"
    }
}

function download(url, destination)
    local res = http.get(url)
    if url then
        local file = io.open(destination, "w")
        if file then
            file:write(res.readAll())
            file:close()
        else
            error("Could not open file: " .. destination)
        end
    else
        error("Could not retrieve: " .. url)
    end
end

function makeStartup(startupLines)
    -- create the startup file and write each table value as a line in the file
    if fs.exists("startup") then fs.delete("startup") end

    print("Creating startup file...")
    local startupFile = fs.open("startup", "w")
    for id, line in ipairs(startupLines) do
        startupFile.writeLine(line)
    end
    startupFile.close()
end

function main(args)
    if #args < 1 then return false end
    local type = args[1]

    if type ~= "shoutBox" and type ~= "shoutCatcher" and type ~= "shoutRoute" then return false end


    for _, file in pairs(file_list[type]) do

        if fs.exists(file) then fs.delete(file) end

        print("Downloading: " .. url .. file)
        download(url .. file,file)

        -- if we're the main file file_list{type[1]] make a startup file
        if file == file_list[type][1] then
            print("Making startup file for: ".. file)
            local startupLines = {
                "-- shoutDeploy generated startup for: ".. file
                ,""
                ,"alwaysgit = false"
                ,""
                ,"--shoutAPI aka shoutIncludes.lua"
                ,"if fs.exists(\"shoutIncludes.lua\") ~= true then error(\"shoutIncludes.lua missing.  try running: deploy ".. type .."\") end"
                ,"fs.move(\"shoutIncludes.lua\",\"shoutAPI\")"
                ,"os.loadAPI(\"shoutAPI\")"
                ,"fs.move(\"shoutAPI\",\"shoutIncludes.lua\")"
                ,"shoutAPI.openModem()"
                ,""
                ,"if fs.exists(\"".. file .."\") and alwaysgit == true then"
                ,"  fs.delete(\"".. file .."\")"
                ,"  fs.delete(\"startup\")"
                ,"  fs.delete(\"deploy\")"
                ,"  shell.run(\"pastebin\",\"get\",\"5DDbea5A\",\"deploy\")"
                ,"  shell.run(\"deploy ".. type .."\")"
                ,"end"
                ,"if fs.exists(\"".. file .."\") then shell.run(\"".. file .."\") end"
            }

            makeStartup(startupLines)

        end
    end

    return true
end


if not main(args) then
    print("Usage: deploy <shoutBox/shoutCatcher/shoutRoute>")
else
    print("")
    print("OK.  Should be ready for reboot but you may want to double-check the ./startup")
end