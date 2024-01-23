if SERVER then return end --prevents it from running on the server

--the purpose of this script is to provide a set of commands available to the player
--it lets them switch options on or off or change various thresholds or speeds


local configDescriptions = {}
configDescriptions["commands"] = "you can use antigrief or ag"
configDescriptions["reset"] = "reset settings to default values EX: ag reset"
configDescriptions["threshold"] = "How many sus points a player must get before alarms go off. Default is 20. EX: ag threshold 30"
configDescriptions["decaytime"] = "How fast players lose sus points in milliseconds. Default is 5000. Players cannot go below 0. EX: ag decaytime 4000"
configDescriptions["add"] = "Add (or update) an item on the list of suspicious items. Num is suspicion level EX: ag add screwdriver 5"
configDescriptions["remove"] = "Remove an item to the list of suspicious items. EX: ag remove screwdriver"
configDescriptions["toggle"] = "Toggles various alarms on/off. Choices are: self, reactor, undock, wiring EX: ag toggle self"
configDescriptions["ban"] = "Adds player to personal banlist. Use this if you are not the host. EX ag ban playername reason(optional)"


local function writeConfig(newConfig)
	File.Write(AntiGrief.path .. "/config.json", json.serialize(newConfig))
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
		AntiGrief.config = {}
		AntiGrief.config = dofile(AntiGrief.path .. "/Lua/defaultConfig.lua")
		writeConfig(dofile(AntiGrief.path .. "/Lua/defaultConfig.lua"))
	end
	
	if command[1] == "threshold" then
		if isInteger(command[2]) then
			print("Changing suspicion threhold!")
			AntiGrief.config.susThreshold = tonumber(command[2])
			writeConfig(AntiGrief.config)
		else
			print("Number not supplied, changing nothing.")
		end
	end
	
	if command[1] == "decaytime" then
		if isInteger(command[2]) then
			print("Changing decay time!")
			AntiGrief.config.decayTime = tonumber(command[2])
			writeConfig(AntiGrief.config)
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
				AntiGrief.config.susTable[command[2]] = tonumber(command[3])
				writeConfig(AntiGrief.config)
			end
		else
			print("Number not supplied, changing nothing.")
		end
	end
	
	if command[1] == "remove" then
	
		if AntiGrief.config.susTable[command[2]] ~= nil then
			print("Removing item!")
			local newTable = dofile(AntiGrief.path .. "/Lua/defaultConfig.lua")
			addMissingEntriesWithExclusionRecursive(AntiGrief.config, newTable, command[2])
			writeConfig(newTable)
			AntiGrief.config = newTable
		else
			print("Item not found in the table.")
		end
	end
	
	if command[1] == "toggle" then
	
		if command[2] == "self" then
			AntiGrief.config.selfAlarmEnabled = not AntiGrief.config.selfAlarmEnabled
			writeConfig(AntiGrief.config)
			print("Self Alarm Active: " .. tostring(AntiGrief.config.selfAlarmEnabled))
		end
		
		if command[2] == "reactor" then
			AntiGrief.config.reactorAlarmEnabled = not AntiGrief.config.reactorAlarmEnabled
			writeConfig(AntiGrief.config)
			print("Reactor Alarm Active: " .. tostring(AntiGrief.config.reactorAlarmEnabled))
		end
		
		if command[2] == "undock" then
			AntiGrief.config.undockAlarmEnabled = not AntiGrief.config.undockAlarmEnabled
			writeConfig(AntiGrief.config)
			print("Undock Alarm Active: " .. tostring(AntiGrief.config.undockAlarmEnabled))
		end
		
		if command[2] == "wiring" then
			AntiGrief.config.wiringAlarmEnabled = not AntiGrief.config.wiringAlarmEnabled
			writeConfig(AntiGrief.config)
			print("Wiring Alarm Active: " .. tostring(AntiGrief.config.wiringAlarmEnabled))
		end
		
	end
	
	if command[1] == "ban" then
		local clientID = AntiGrief.getClientIDFromName(command[2])
		local reason = "Anti Grief"
		if command[3] ~= nil then reason = command[3] end
		if clientID ~= "" then
			--ban the player
			local personalBanListPath = AntiGrief.path .. "/bannedplayers.txt"
			local newLineToAdd = '  <ban name="' .. command[2] .. '" reason="' .. reason .. '" accountid="' .. tostring(clientID) .. '" />\n'

			if File.Exists(personalBanListPath) then
				local bannedPlayerList = File.Read(personalBanListPath)
				bannedPlayerList = bannedPlayerList .. newLineToAdd
				File.Write(personalBanListPath, bannedPlayerList)
			else
				File.Write(personalBanListPath, newLineToAdd)
			end
				
			print("Name exported to list. This is NOT your actual banlist.")
			print("Actual banning will happen automatically next time you host a server.")
		else
			print("Player not found. Names are case sensitive.")
		end
		
	end
	
	
	if checkStringAgainstTags(command[1], configDescriptions) then
		--print("Match found!")
	else
		print("Command not recognized. type gd to see available commands.")
	end
	
end

Game.AddCommand("antigrief", "configures antigrief", function (command)
	runCommand(command)
end)


Game.AddCommand("ag", "configures antigrief abbreviated", function (command)
	runCommand(command)
end)

