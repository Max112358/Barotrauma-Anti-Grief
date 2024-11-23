if SERVER then return end --prevents it from running on the server


local crosshairIcon = Sprite(AntiGrief.path .. "/crosshairs.png")
local color = Color(128, 128, 128, 64)
local rotation = 0
local scale = 1
local listOfDetonators = {}


local function findAllDetonators()
	Timer.Wait(findAllDetonators, 1000) --recursively run again every milliseconds

	if Submarine == nil then return end
	if Submarine.MainSub == nil then return end
	local allItems = Submarine.MainSub.GetItems(false)

	listOfDetonators = {} --blank the list so it doesnt add duplicates. also removes old ones.
	for _, item in pairs(allItems) do
		--if item.Prefab.Identifier == "detonator" then
		if item.HasTag("detonator") then
			table.insert(listOfDetonators, item)
		end
	end
	
end

-- Start the timer initially
findAllDetonators()


Hook.Patch("Barotrauma.Inventory", "DrawSlot", function(instance, ptable) --unsure why this has to be inventory. "Barotrauma.GameScreen" does not work for reasons I dont understand
	local spriteBatch = ptable["spriteBatch"]
	
	if listOfDetonators == nil then return end
	if AntiGrief.config.markDetonatorsEnabled == false then return end
	
	for _, item in pairs(listOfDetonators) do
		if item ~= nil then
		
			if item.ParentInventory == nil then
				pos = Screen.Selected.Cam.WorldToScreen(item.WorldPosition);
				pos.X = pos.X - 64
				pos.Y = pos.Y - 64
				crosshairIcon.Draw(spriteBatch, pos, color, rotation, scale)
			end
		end
	end
	
	
end, Hook.HookMethodType.After)