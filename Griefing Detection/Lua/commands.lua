
local configDescriptions = {}
configDescriptions["commands"] = "you can use grief, greif, gd or griefingdetector"
configDescriptions["reset"] = "reset settings to default values EX: gd reset"
configDescriptions["threshold"] = "How many sus points a player must get before alarms go off. Default is 20. EX: gd threshold 30"
configDescriptions["decaytime"] = "How fast players lose sus points in milliseconds. Default is 5000. Players cannot go below 0. EX: gd decaytime 4000"
configDescriptions["add"] = "Add (or update) an item on the list of suspicious items. Num is suspicion level EX: gd add screwdriver 5"
configDescriptions["remove"] = "Remove an item to the list of suspicious items. EX: gd remove screwdriver"
configDescriptions["toggle"] = "Toggles various alarms on/off. Choices are: self, reactor, undock, wiring"


local function writeConfig(newConfig)
	File.Write(path .. "/config.json", json.serialize(newConfig))
end


local function isInteger(str)
    return str and not (str == "" or str:find("%D"))
end

local function addMissingEntriesWithExclusionRecursive(table1, table2, excludedKey)
    for key, value in pairs(table1) do
        if key ~= excludedKey then
            if type(value) == "table" and type(table2[key]) == "table" then
                -- If both values are tables, recursively merge them
                addMissingEntriesWithExclusionRecursive(value, table2[key], excludedKey)
            else
                -- Otherwise, set the value directly
                table2[key] = value
            end
        end
    end
end

local function checkStringAgainstTags(targetString, tags)
    for tag, _ in pairs(tags) do
        if targetString == tag then
            return true  -- Match found
        end
    end
    return false  -- No match found
end


local function runCommand(command)
	if command[1] == nil or command[1] == "help" or command[1] == "commands" then
		for key, value in pairs(configDescriptions) do
			print(key .. ": " .. value)
		end
	end
	
	if command[1] == "reset" then
		print("Resetting to default!")
		config = {}
		config = dofile(path .. "/Lua/defaultConfig.lua")
		writeConfig(dofile(path .. "/Lua/defaultConfig.lua"))
	end
	
	if command[1] == "threshold" then
		if isInteger(command[2]) then
			print("Changing suspicion threhold!")
			config.susThreshold = tonumber(command[2])
			writeConfig(config)
		else
			print("Number not supplied, changing nothing.")
		end
	end
	
	if command[1] == "decaytime" then
		if isInteger(command[2]) then
			print("Changing decay time!")
			config.decayTime = tonumber(command[2])
			writeConfig(config)
		else
			print("Number not supplied, changing nothing.")
		end
	end
	
	if command[1] == "add" then
		if isInteger(command[3]) then
			local prefab = ItemPrefab.GetItemPrefab(command[2])
			if prefab == nil then
				print("could not find item with the id/name \"", command[2], "\"")
			else
				print("Adding item!")
				config.susTable[command[2]] = tonumber(command[3])
				writeConfig(config)
			end
		else
			print("Number not supplied, changing nothing.")
		end
	end
	
	if command[1] == "remove" then
	
		if config.susTable[command[2]] ~= nil then
			print("Removing item!")
			local newTable = dofile(path .. "/Lua/defaultConfig.lua")
			addMissingEntriesWithExclusionRecursive(config, newTable, command[2])
			writeConfig(newTable)
			config = newTable
		else
			print("Item not found in the table.")
		end
	end
	
	if command[1] == "toggle" then
	
		if command[2] == "self" then
			config.selfAlarmEnabled = not config.selfAlarmEnabled
			writeConfig(config)
			print("Self Alarm Active: " .. tostring(config.selfAlarmEnabled))
		end
		
		if command[2] == "reactor" then
			config.reactorAlarmEnabled = not config.reactorAlarmEnabled
			writeConfig(config)
			print("Reactor Alarm Active: " .. tostring(config.reactorAlarmEnabled))
		end
		
		if command[2] == "undock" then
			config.undockAlarmEnabled = not config.undockAlarmEnabled
			writeConfig(config)
			print("Undock Alarm Active: " .. tostring(config.undockAlarmEnabled))
		end
		
		if command[2] == "wiring" then
			config.wiringAlarmEnabled = not config.wiringAlarmEnabled
			writeConfig(config)
			print("Wiring Alarm Active: " .. tostring(config.wiringAlarmEnabled))
		end
		
	end
	
	
	if checkStringAgainstTags(command[1], configDescriptions) then
		--print("Match found!")
	else
		print("Command not recognized. type gd to see available commands.")
	end
	
end

Game.AddCommand("grief", "configures griefing detector", function (command)
	runCommand(command)
end)

Game.AddCommand("greif", "configures griefing detector mispelled", function (command)
	runCommand(command)
end)

Game.AddCommand("gd", "configures griefing detector abbreviated", function (command)
	runCommand(command)
end)

Game.AddCommand("griefingdetector", "configures griefing detector full name", function (command)
	runCommand(command)
end)