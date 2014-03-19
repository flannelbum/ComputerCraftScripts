-- shoutIncludes.lua  -  generally helpful functions and globals and junk.
--  This gets renamed on load to shoutAPI via generated startup file.


-- run by startup
function openModem()
    for i, v in pairs(rs.getSides()) do
        if peripheral.getType(v) == "modem" then
            if not rednet.isOpen(v) then
                rednet.open(v)
            end
            print("modem opened on the "..v)
            return true
        end
    end
    print("no modem found")
    return false
end

function getMonitor()
    for i, v in pairs(rs.getSides()) do
        if peripheral.getType(v) == "monitor" then
            v = peripheral.wrap(v)
            return v
        end
    end
    return nil
end

function msgLog(id, msg, d)
    local logfile
    -- if our log is too big, how helpful is it?  let's toast it and start again
    -- measured in bytes... this be 4k which feels kinda big.  we'll see.
    if fs.exists("msgLog") == true and fs.getSize("msgLog") > 4096 then fs.delete("msgLog") end

    if fs.exists("msgLog") == true then
        logfile = fs.open("msgLog", "a")
    else
        logfile = fs.open("msgLog", "w")
    end
    local data = "ID:" .. id .. " MSG: " .. msg .." d:" .. d

    logfile.writeLine(data)
    logfile.close()
    print(data)
end