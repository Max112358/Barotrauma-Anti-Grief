if SERVER then return end --prevents it from running on the server

local function retrieveName(inputString)
    local strippedString = inputString:gsub("[^%w%s]", "")
	local leftSide = string.match(strippedString, "(.-)" .. "end " .. "(.+)")
	local nextStep = string.match(leftSide, "%d(.+)")
	local finalized = nextStep:gsub("%d", "")
    return finalized
end

local configPath = path .. "/config.json"

-- Use the constructed path. path is a global stored in init
local sound = Game.SoundManager.LoadSound(path .. "/alert.ogg")
-- Function to activate the alarm
local function activateAlarm(printStatement)
	print(printStatement)
	local myPos = Character.Controlled --center on the controlled character
	sound.Play(10, 100000, myPos)
end


--this works with the server side script to detect wiring changes. this will not work if the mod isnt running on the server.
Hook.Add("chatMessage", "serverChatRecieve", function (message, client)
	if client ~= nil then return end --do nothing if its not from the server
	
	local foundIt = false
	for _, filter in ipairs(messageFilters) do
		if string.find(message, filter) then 
			foundIt = true
		end
	end
	if foundIt == false then return true end
	
	
	config = json.parse(File.Read(configPath)) -- I have no idea why this is needed. Somehow its not recognizing changes to the global config without it. Reference error somehow?
	
	local strippedName = retrieveName(message);
	
	
	
	
	local isYou = false
	if Character.Controlled ~= nil then
		isYou = (Character.Controlled.name == strippedName)
	end
	
	
	if (isYou and not config.selfAlarmEnabled) then return true end --if its your character and self alarm not active, abort

	
	if (string.find(message, "wire")) and config.wiringAlarmEnabled then
		activateAlarm(message)
	end
	
	if (string.find(message, "undocked")) and config.undockAlarmEnabled then
		activateAlarm(message)
	end
	
	if (string.find(message, "Fission")) and config.reactorAlarmEnabled then
		activateAlarm(message)
	end
	
	
    return true -- returning true allows us to hide the message
end)