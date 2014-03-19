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

function msgLog(id, msg, d)
    local data = "ID:" .. id .. " MSG: " .. msg .." d:" .. d
    local logfile = fs.open("msgLog", "a")
    logfile.writeLine(data)
    logfile.close()
    print(data)
end