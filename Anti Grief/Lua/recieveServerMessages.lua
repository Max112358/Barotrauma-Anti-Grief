if SERVER then return end --prevents it from running on the server


--the purpose of this script is to recieve messages from the server for events that the client cannot read
--prints done in the server log hook do not work reliably because each server log generates its own event, which forms an infinite loop
--so this is a way of getting around that print restriction

local function retrieveName(inputString)
    local strippedString = inputString:gsub("[^%w%s]", "")
	local leftSide = string.match(strippedString, "(.-)" .. "end " .. "(.+)")
	local nextStep = string.match(leftSide, "%d(.+)")
	local name = nextStep:gsub("%d", "")
    return name
end


--this works with the server side script to detect wiring changes. this will not work if the mod isnt running on the server.
Hook.Add("chatMessage", "serverChatRecieve", function (message, client)
	if client ~= nil then return end --do nothing if its not from the server
	
	local containsKeyWord = false
	for _, filter in ipairs(AntiGrief.messageFilters) do
		if string.find(message, filter) then 
			containsKeyWord = true
		end
	end
	if containsKeyWord == false then return true end
	
	
	AntiGrief.config = json.parse(File.Read(AntiGrief.configPath)) -- I have no idea why this is needed. Somehow its not recognizing changes to the global config without it. Reference error somehow?
	
	
	local strippedName = retrieveName(message);
	local isYou = false
	if Character.Controlled ~= nil then
		isYou = (Character.Controlled.name == strippedName)
	end
	
	
	if (isYou and not AntiGrief.config.selfAlarmEnabled) then return true end --if its your character and self alarm not active, abort
	
	if (string.find(message, "wire")) and AntiGrief.config.wiringAlarmEnabled then
		AntiGrief.activateAlarm(message)
	end
	
	if (string.find(message, "undocked")) and AntiGrief.config.undockAlarmEnabled then
		AntiGrief.activateAlarm(message)
	end
	
	if (string.find(message, "Fission")) and AntiGrief.config.reactorAlarmEnabled then
		AntiGrief.activateAlarm(message)
	end
	
	
    return true -- returning true allows us to hide the message
end)
