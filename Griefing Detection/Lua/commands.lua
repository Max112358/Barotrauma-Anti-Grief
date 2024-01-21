if SERVER then return end --prevents it from running on the server

--the purpose of this script is to provide a set of commands available to the player
--it lets them switch options on or off or change various thresholds or speeds


local configDescriptions = {}
configDescriptions["commands"] = "you can use grief, greif, gd or griefingdetector"
configDescriptions["reset"] = "reset settings to default values EX: gd reset"
configDescriptions["threshold"] = "How many sus points a player must get before alarms go off. Default is 20. EX: gd threshold 30"
configDescriptions["decaytime"] = "How fast players lose sus points in milliseconds. Default is 5000. Players cannot go below 0. EX: gd decaytime 4000"
configDescriptions["add"] = "Add (or update) an item on the list of suspicious items. Num is suspicion level EX: gd add screwdriver 5"
configDescriptions["remove"] = "Remove an item to the list of suspicious items. EX: gd remove screwdriver"
configDescriptions["toggle"] = "Toggles various alarms on/off. Choices are: self, reactor, undock, wiring"
configDescriptions["ban"] = "Adds player to personal banlist. Use this if you are not the host. EX gd ban playername reason(optional)"


local function writeConfig(newConfig)
	File.Write(griefingDetectionPath .. "/config.json", json.serialize(newConfig))
end


local function isInteger(str)
    return str and not (str == "" or str:find("%D"))
end

-- Function to find the AccountId id from a given character
local function getClientIDFromName(passedName)
	local clientID = ""
	for key, client in pairs(Client.ClientList) do
		if client.Character == nil then goto continue end
		if client.Character.name == passedName then
			clientID = client.AccountId
		end
		::continue::
	end
	return clientID
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
		griefingDetectionConfig = {}
		griefingDetectionConfig = dofile(griefingDetectionPath .. "/Lua/defaultConfig.lua")
		writeConfig(dofile(griefingDetectionPath .. "/Lua/defaultConfig.lua"))
	end
	
	if command[1] == "threshold" then
		if isInteger(command[2]) then
			print("Changing suspicion threhold!")
			griefingDetectionConfig.susThreshold = tonumber(command[2])
			writeConfig(griefingDetectionConfig)
		else
			print("Number not supplied, changing nothing.")
		end
	end
	
	if command[1] == "decaytime" then
		if isInteger(command[2]) then
			print("Changing decay time!")
			griefingDetectionConfig.decayTime = tonumber(command[2])
			writeConfig(griefingDetectionConfig)
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
				griefingDetectionConfig.susTable[command[2]] = tonumber(command[3])
				writeConfig(griefingDetectionConfig)
			end
		else
			print("Number not supplied, changing nothing.")
		end
	end
	
	if command[1] == "remove" then
	
		if griefingDetectionConfig.susTable[command[2]] ~= nil then
			print("Removing item!")
			local newTable = dofile(griefingDetectionPath .. "/Lua/defaultConfig.lua")
			addMissingEntriesWithExclusionRecursive(griefingDetectionConfig, newTable, command[2])
			writeConfig(newTable)
			griefingDetectionConfig = newTable
		else
			print("Item not found in the table.")
		end
	end
	
	if command[1] == "toggle" then
	
		if command[2] == "self" then
			griefingDetectionConfig.selfAlarmEnabled = not griefingDetectionConfig.selfAlarmEnabled
			writeConfig(griefingDetectionConfig)
			print("Self Alarm Active: " .. tostring(griefingDetectionConfig.selfAlarmEnabled))
		end
		
		if command[2] == "reactor" then
			griefingDetectionConfig.reactorAlarmEnabled = not griefingDetectionConfig.reactorAlarmEnabled
			writeConfig(griefingDetectionConfig)
			print("Reactor Alarm Active: " .. tostring(griefingDetectionConfig.reactorAlarmEnabled))
		end
		
		if command[2] == "undock" then
			griefingDetectionConfig.undockAlarmEnabled = not griefingDetectionConfig.undockAlarmEnabled
			writeConfig(griefingDetectionConfig)
			print("Undock Alarm Active: " .. tostring(griefingDetectionConfig.undockAlarmEnabled))
		end
		
		if command[2] == "wiring" then
			griefingDetectionConfig.wiringAlarmEnabled = not griefingDetectionConfig.wiringAlarmEnabled
			writeConfig(griefingDetectionConfig)
			print("Wiring Alarm Active: " .. tostring(griefingDetectionConfig.wiringAlarmEnabled))
		end
		
	end
	
	if command[1] == "ban" then
		local clientID = getClientIDFromName(command[2])
		local reason = "Griefing Detector"
		if command[3] ~= nil then reason = command[3] end
		if clientID ~= "" then
			--ban the player
			local personalBanListPath = griefingDetectionPath .. "/bannedplayers.txt"
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
