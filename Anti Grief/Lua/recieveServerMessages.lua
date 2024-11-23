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
Hook.Add("chatMessage", "AntiGriefserverChatRecieve", function (message, client)
	if client ~= nil then return end --do nothing if its not from the server
	
	if not (string.find(message, AntiGrief.messageFilter)) then return end --do nothing if not from the mod
	
	local strippedName = retrieveName(message);
	if AntiGrief.shouldIgnoreThisPersonForAlarms(strippedName) then return true end
	
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
