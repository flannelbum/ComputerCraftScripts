--name dropbox
--version 2

local tArgs = {...} --read in arguments

function out(str) -- function to print only if the argument true is not passed in
	if tArgs[1] ~= "true" then
		print(str)
	end
end

function download(address)
	site = http.get(address) -- sets site to the file found at address
	if site == nil then -- if there is no file, print "No file" and skip the rest of the program
		print("No file")
	else
		code = site.readAll() -- read the whole file and put it in code
		bool = true -- temp variable for loop
		i = 1 -- temp variable for loop
		start = 0 -- temp variable for loop
		while bool do -- find the rightmost "/" in the address
			start = string.find(address, "/", string.len(address)-i, true)
			i = i + 1
			if start ~= nil then
				name = string.sub(address, start+1) -- sets name to the part of the address to the right of the last "/"
				bool = false
			end
			if i > string.len(address) then -- if i gets bigger than the address and no "/" is found, name the file "noname"
				name = "noname"
				bool = false
			end
		end

		firstline = string.find(code, "\n") -- finds the end of the first line
		if firstline == nil then -- if the code does not have an end of line, set firstline to the length of code
			firstline = string.len(code)
		end
		firstname = string.find(code, "--name") -- tries to find "--name"
		name2 = nil -- name2 defaults to nil
		if firstname ~= nil then -- if "--name" was found
			if firstname < firstline then -- and if it was on the first line
				name2 = string.sub(code, 8, firstline-1) -- set name2 to the new name
			end
		end
		
		out("Downloaded: \""..name.."\"") -- use the out function to print "Downloaded: name"
		if name2 ~= nil then -- if there was a name2, print "renamed to: name2"
			out("renamed to: \""..name2.."\"")
		end
		
		versionline = string.find(code, "--version") -- find the line "--version" is on
		versionend = string.find(code, "\n", versionline) -- find the end of that line
		secondline = string.find(code, "\n", firstline+1) -- find the end of the second line
		if secondline == nil then  -- if the code does not have a second end of line, set secondline to the length of code
			secondline = string.len(code)
		end
		if versionline ~= nil then -- checks that "--version" exists
			if versionline < secondline then -- checks that it exists on one of the first 2 lines
				out("Version: "..string.sub(code, versionline+10, versionend-1)) -- prints "Version: " and then the version number
			end
		end

		if name2 ~= nil then -- if name2 exists, open a file with that name
			file = fs.open(name2,"w")
		else -- else open a file with name
			file = fs.open(name,"w")
		end
		file.write(code) -- write code to that file
		file.close() -- and close it
	end
end

function files() -- reads in the file "dropboxfiles" and returns an array with all the urls
	file = fs.open("dropboxfiles","r") -- opens the file
	hasline = true -- temp variable
	files = {} -- initialize array
	i = 1 -- temp variable
	while hasline do -- while we have another line
		line = file.readLine() -- read the line
		if line == nil then -- if it is nil, there are no more lines
			hasline = false
		else -- else write the url to the array
			files[i] = line
		end
		i = i + 1
	end
	return files -- return the array
end

urls = files() -- read the file
for i=1,#urls do -- download from the urls
	download(urls[i])
end