if SERVER then return end --prevents it from running on the server


local crosshairIcon = Sprite(AntiGrief.path .. "/crosshairs.png")
local color = Color(128, 128, 128, 64)
local rotation = 0
local scale = 1
local listOfDetonators = {}


local function findAllDetonators()
	Timer.Wait(findAllDetonators, 1000) --recursively run again every X seconds, where X is in miliseconds

	if Submarine == nil then return end
	if Submarine.MainSub == nil then return end
	local allItems = Submarine.MainSub.GetItems(false)

	listOfDetonators = {}
	for _, item in pairs(allItems) do
		if item.Prefab.Identifier == "detonator" then
			table.insert(listOfDetonators, item)
		end
	end
	
end

-- Start the timer initially
findAllDetonators()


Hook.Patch("Barotrauma.Inventory", "DrawSlot", function(instance, ptable) --unsure why this has to be inventory. "Barotrauma.GameScreen" does not work for reasons I dont understand
	local spriteBatch = ptable["spriteBatch"]
	
	if listOfDetonators == nil then return end
	
	for _, item in pairs(listOfDetonators) do
		if item ~= nil then
			pos = Screen.Selected.Cam.WorldToScreen(item.WorldPosition);

			pos.X = pos.X - 64
			pos.Y = pos.Y - 64

			--local angleRad = math.rad(rotation)  -- Convert degrees to radians
			--local radius = 0
			--local x =  math.cos(angleRad)
			--local y =  math.sin(angleRad)
			--pos.X = pos.X + math.cos(angleRad) * radius
			--pos.Y = pos.Y + math.sin(angleRad) * radius
				
			crosshairIcon.Draw(spriteBatch, pos, color, rotation, scale)
		end
	end
	
	
end, Hook.HookMethodType.After)