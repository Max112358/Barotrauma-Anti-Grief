--print("your local mod is running")

if SERVER then return end --prevents it from running on the server
--this script runs CLIENT SIDE!!! clients cannot see the serverLog, so cannot detect wiring issues or the reactor

local breathingDevices = {"Diving Mask", "Diving Suit", "Combat Diving Suit", "Abyss Diving Suit", "PUCS", "Slipsuit", "Clown Diving Mask", "Exosuit", "Funbringer 3000"}

local susThreshold = 20 --tolerance for how suspicious someone can act before alarms go off
local susPoints = {} --every time someone does something suspicious, add points. Ring alarm beyond threshold.

local susTable = { --how suspicious using a given item is
    ["Fentanyl"] = 11,
    ["Morphine"] = 4,
    ["Opium"] = 3,
    ["Fuel Rod"] = 11,
    ["Thorium Fuel Rod"] = 11,
    ["Rum"] = 11,
    ["Ethanol"] = 8,
    ["Calyxanide"] = 11,
	
	--ultra sus items beyond this point
	["Deliriumine"] = 25,
	["Velonaceps Calyx Eggs"] = 25,
	["Calyx Extract"] = 25,
	["Cyanide"] = 25,
	["Radiotoxin"] = 25,
	["Sufforin"] = 25,
	["Paralyzant"] = 25,
	["Chloral Hydrate"] = 25,
	["Morbusine"] = 25,
	["Detonator"] = 25,
	["Nitroglycerin"] = 25,
	["Incendium Grenade"] = 25,
	["Frag Grenade"] = 25,
	["Stun Grenade"] = 25,
	["EMP Grenade"] = 25,
	["Oxygenite Shard"] = 25,
	["Nuclear Shell"] = 25
}


-- Function to update player scores
function increaseSusPoints(playerName, amountToIncrease)
    -- Check if the player is already in the table
    if susPoints[playerName] then
        -- Player is already in the table, increment their score
        susPoints[playerName] = susPoints[playerName] + amountToIncrease
    else
        -- Player is not in the table, add them with a score of 1
        susPoints[playerName] = amountToIncrease
    end
end

-- Function to reduce points for all players
function reducePointsForAll()

    for playerName, score in pairs(susPoints) do
        -- Decrement the score by 1
		if susPoints[playerName] > 0 then
			susPoints[playerName] = score - 1
		end
    end
	
	Timer.Wait(reducePointsForAll, 5000)
end

-- Start the timer initially
reducePointsForAll()


--get the local path
local path = ...
 
 -- Ensure there is a slash at the end of the path
if not path:match("[/\\]$") then
    path = path .. "/"
end
 
-- Use the constructed path
local sound = Game.SoundManager.LoadSound(path .. "alert.ogg")


--equipped an item
Hook.Add("item.equip", "equippedAnItem", function(item, character)
   
   local isSuspicious = false
   
   --check against the sus table to see if the item is bad
	for itemName, suspicionLevel in pairs(susTable) do
		if itemName == item.name and character ~= nil then
			increaseSusPoints(character.Name, suspicionLevel)
			if susPoints[character.Name] > susThreshold then 
				isSuspicious = true
			end
			break -- Exit the loop if a match is found
		end
	end
   

   if isSuspicious then
	   -- Do something when the item is suspicious
	   print(character.name .. " has equipped " .. item.name .. "!!!!")
	   local myPos = Character.Controlled
	   sound.Play(10, 100000, myPos)
   end
end)



--dropped an item
Hook.Add("item.drop", "droppedAnItem", function(item, character)
   
   local isSuspicious = false
   
   --check against the sus table to see if the item is bad
	for itemName, suspicionLevel in pairs(susTable) do
		if itemName == item.name and character ~= nil then
			increaseSusPoints(character.Name, suspicionLevel)
			if susPoints[character.Name] > susThreshold then 
				isSuspicious = true
			end
			break -- Exit the loop if a match is found
		end
	end

	if isSuspicious then
		-- Do something when the item is suspicious
		print(character.name .. " has dropped " .. item.name .. "!!!!")
		local myPos = Character.Controlled
		sound.Play(10, 100000, myPos)
	end
   
end)



--applied an item
Hook.Add("item.applyTreatment", "appliedTreatment", function(item, usingCharacter, targetCharacter, limb)
   
	
	--logging items that are suspicious to use in large amounts. No immediate alarm on this, just keep an eye on it.
	for itemName, suspicionLevel in pairs(susTable) do
		if itemName == item.name and usingCharacter ~= nil then
			increaseSusPoints(usingCharacter.Name, suspicionLevel)
			if susPoints[usingCharacter.Name] > susThreshold then 
				isSuspicious = true
			end
			break -- Exit the loop if a match is found
		end
	end
   

   if isSuspicious then
	   -- Do something when the item is suspicious
	   print(usingCharacter.name .. " has applied " .. item.name .. " to " .. targetCharacter.name .. "!!!!")
	   local myPos = Character.Controlled
	   sound.Play(10, 100000, myPos)
   end
   
end)

--used an item
Hook.Add("item.use", "usedItem", function(item, itemUser, targetLimb)
   
   --logging items that are suspicious to use in large amounts. No immediate alarm on this, just keep an eye on it.
	for itemName, suspicionLevel in pairs(susTable) do
		if itemName == item.name and itemUser ~= nil then
			increaseSusPoints(itemUser.Name, suspicionLevel)
			if susPoints[itemUser.Name] > susThreshold then 
				isSuspicious = true
			end
			break -- Exit the loop if a match is found
		end
	end
   

   if isSuspicious then
	   -- Do something when the item is suspicious
	   print(itemUser.name .. " has used " .. item.name .. "!!!!")
	   local myPos = Character.Controlled
	   sound.Play(10, 100000, myPos)
   end
   
end)

--moved item to inventory 
Hook.Add("inventoryPutItem", "transferredAnItem", function(inventory, item, characterUser)
   
   -- Check if item.name matches any entry in susTable
   local isSuspicious = false
   
	--if they put welding fuel in a suit or mask
	for _, itemName in ipairs(breathingDevices) do
	  if item.name == "Welding Fuel Tank" and inventory.owner.name == itemName then
		 isSuspicious = true
		 break
	  end
	end
	
	--if they put incendium fuel in a suit or mask
	for _, itemName in ipairs(breathingDevices) do
	  if item.name == "Incendium Fuel Tank" and inventory.owner.name == itemName then
		 isSuspicious = true
		 break
	  end
	end
   
	--if they made a welder bomb
	if item.name == "Oxygen Tank" and inventory.owner.name == "Welding Tool" then
		isSuspicious = true
	end
	
	--more ways to welder bomb
	if item.name == "Oxygenite Tank" and inventory.owner.name == "Welding Tool" then
		isSuspicious = true
	end
	
	--logging items that are suspicious to use in large amounts. No immediate alarm on this, just keep an eye on it.
	for itemName, suspicionLevel in pairs(susTable) do
		if itemName == item.name and characterUser ~= nil then
			print(characterUser.Name .. " has transferred " .. item.name .. " to " .. inventory.owner.name .. ".")
			
			if suspicionLevel > susThreshold then
				increaseSusPoints(characterUser.Name, suspicionLevel) --for items that are immediately suspicious
			else
				increaseSusPoints(characterUser.Name, 1) --for normal items like fuel rods
			end
			
			if susPoints[characterUser.Name] > susThreshold then 
				isSuspicious = true
			end
			break -- Exit the loop if a match is found
		end
	end

   if isSuspicious and characterUser ~= nil then
	   -- Do something when the item is suspicious
	   print(characterUser.Name .. " has transferred " .. item.name .. " to " .. inventory.owner.name .. "!!!!")
	   local myPos = Character.Controlled
	   sound.Play(10, 100000, myPos)
   end
end)


--this works with the server side script to detect wiring changes. this will not work if the mod isnt running on the server.
Hook.Add("chatMessage", "wiringRecieve", function (message, client)
	if client ~= nil then return end --do nothing if its not from the server

	--check if someone is sabotaging the reactor
	if string.find(message, "Fission rate:") then
		print(message)
		local myPos = Character.Controlled
		sound.Play(10, 100000, myPos)
	end

	--check if someone is messing with wiring
	if string.find(message, "wire") then
		print(message)
		local myPos = Character.Controlled
		sound.Play(10, 100000, myPos)
	end
	
	--check if someone is messing with the drone
	if string.find(message, "undocked") then
		print(message)
		local myPos = Character.Controlled
		sound.Play(10, 100000, myPos)
	end

    return true -- returning true allows us to hide the message
end)