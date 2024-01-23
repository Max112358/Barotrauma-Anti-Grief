if SERVER then return end --prevents it from running on the server

--the purpose of this script is to check the actions of all players and sound an alarm if they seem suspicious

local susPoints = {} --every time someone does something suspicious, add points. Ring alarm beyond threshold.
local clientID = ""


-- Function to update player scores
local function increaseSusPoints(playerName, amountToIncrease)
    -- Check if the player is already in the table
    if susPoints[playerName] then
        -- Player is already in the table, increment their score
        susPoints[playerName] = susPoints[playerName] + amountToIncrease
    else
        -- Player is not in the table, add them with a score of whatever
        susPoints[playerName] = amountToIncrease
    end
end

-- Function to reduce points for all players
local function reducePointsForAll()

    for playerName, score in pairs(susPoints) do
        -- Decrement the score by 1
		if susPoints[playerName] > 0 then
			susPoints[playerName] = score - 1
		end
    end
	
	Timer.Wait(reducePointsForAll, AntiGrief.config.decayTime) --recursively run again every X seconds, where X is decayTime
end

-- Start the timer initially
reducePointsForAll()


-- standard operation of a hook
local function hookBoilerPlate(item, paramCharacter)

	local isSuspicious = false
	
	if paramCharacter == nil then return false end
	clientID = AntiGrief.getClientID(paramCharacter)
	if clientID == "" then return end

	AntiGrief.config = json.parse(File.Read(AntiGrief.configPath)) -- I have no idea why this is needed. Somehow its not recognizing changes to the global AntiGrief.config without it. Reference error somehow?
   
	local isYou = false
	--if client ~= nil then
	if Character.Controlled ~= nil then
		isYou = (Character.Controlled.name == paramCharacter.name)
	end
	
	if (isYou and not AntiGrief.config.selfAlarmEnabled) then return false end --if its your character and self alarm not active, abort
   
	--check against the sus table to see if the item is bad
	for itemName, suspicionLevel in pairs(AntiGrief.config.susTable) do
		if itemName == item.Prefab.Identifier then
			increaseSusPoints(paramCharacter.Name, suspicionLevel)
			if susPoints[paramCharacter.Name] > AntiGrief.config.susThreshold then 
				isSuspicious = true
			end
			break -- Exit the loop if a match is found
		end
	end
	
	return isSuspicious
end

--[[
Hook.Add("item.interact", "tagPrinter", function(item, characterPicker, ignoreRequiredItemsBool, forceSelectKeyBool, forceActionKeyBool)
   
	local myTags = item.GetTags()


	print("-------------")
	print(item.Prefab.Identifier)
	print("-------------")

	for tag in myTags do
		print(tag)
	end
	print("-------------")
end)
--]]



--equipped an item
Hook.Add("item.equip", "equippedAnItem", function(item, paramCharacter)
   
	local isSuspicious = hookBoilerPlate(item, paramCharacter)

	if isSuspicious then AntiGrief.activateAlarm(paramCharacter.name .. " has equipped " .. item.name .. "!!!!" .. " Client ID: " .. tostring(clientID)) end
end)

--applied an item
Hook.Add("item.applyTreatment", "appliedTreatment", function(item, usingCharacter, targetCharacter, limb)
   
	local isSuspicious = hookBoilerPlate(item, usingCharacter)
   
	if isSuspicious then AntiGrief.activateAlarm(usingCharacter.name .. " has applied " .. item.Name .. " to " .. targetCharacter.name .. "!!!!" .. " Client ID: " .. tostring(clientID)) end

   
end)

--used an item
Hook.Add("item.use", "usedItem", function(item, itemUser, targetLimb)
   
	local isSuspicious = hookBoilerPlate(item, itemUser)
	
	if isSuspicious then AntiGrief.activateAlarm(itemUser.name .. " has used " .. item.Name .. "!!!!"  .. " Client ID: " .. tostring(clientID)) end
   
end)

--moved item to inventory 
Hook.Add("inventoryPutItem", "transferredAnItem", function(inventory, item, characterUser)
   
   
	if characterUser == nil then return end
   
	AntiGrief.config = json.parse(File.Read(AntiGrief.configPath)) -- I have no idea why this is needed. Somehow its not recognizing changes to the global config without it. Reference error somehow?

	-- Check if item.Name matches any entry in AntiGrief.config.susTable
	local isSuspicious = false
   
	local isYou = false
	if Character.Controlled ~= nil then
		isYou = (Character.Controlled.name == characterUser.name)
	end
	if (isYou and not AntiGrief.config.selfAlarmEnabled) then return end --if its your character and self alarm not active, abort
   
	
	if LuaUserData.IsTargetType(inventory.owner.GetType(), "Barotrauma.Item") then
		--check for welder bombs
		if item.HasTag("oxygensource") and inventory.owner.HasTag("weldingequipment") then
			isSuspicious = true
		end
		
		--check for cutter bombs
		if item.HasTag("weldingfuel") and inventory.owner.HasTag("cuttingequipment") then
			isSuspicious = true
		end
		
		--check for suit/mask poisoning
		if item.HasTag("weldingfuel") and (inventory.owner.HasTag("diving") or  inventory.owner.HasTag("deepdiving")) then
			isSuspicious = true
		end
	end
	
	
	--logging items that are suspicious to use in large amounts. No immediate alarm on this, just keep an eye on it.
	for itemName, suspicionLevel in pairs(AntiGrief.config.susTable) do
		if itemName == item.Prefab.Identifier and characterUser ~= nil then
			print(characterUser.Name .. " has transferred " .. item.name .. " to " .. inventory.owner.name .. ".")
			
			if suspicionLevel > AntiGrief.config.susThreshold then
				increaseSusPoints(characterUser.Name, suspicionLevel) --for items that are immediately suspicious
			else
				increaseSusPoints(characterUser.Name, 1) --for normal items like fuel rods
			end
			
			if susPoints[characterUser.Name] > AntiGrief.config.susThreshold then 
				isSuspicious = true
			end
			break -- Exit the loop if a match is found
		end
	end

	local clientID = AntiGrief.getClientID(characterUser)
	if clientID == "" then return end
	if isSuspicious then AntiGrief.activateAlarm(characterUser.Name .. " has transferred " .. item.name .. " to " .. inventory.owner.name .. "!!!!" .. " Client ID: " .. tostring(clientID)) end
end)
