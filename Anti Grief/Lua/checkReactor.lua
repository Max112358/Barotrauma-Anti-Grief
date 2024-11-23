if SERVER then return end --prevents it from running on the server


local listOfReactors = {}
local last_user_name = nil
local time_of_last_alert = Timer.GetTime()


local function find_all_reactors()
	Timer.Wait(find_all_reactors, 10000) --recursively run again every X milliseconds

	if Submarine == nil then return end
	if Submarine.MainSub == nil then return end
	local allItems = Submarine.MainSub.GetItems(false)

	listOfReactors = {} --blank the list so it doesnt add duplicates. also removes old ones.
	for _, item in pairs(allItems) do
		if item.HasTag("reactor") then
			table.insert(listOfReactors, item)
		end
	end
	
	--[[
	for _, reactor in pairs(listOfReactors) do
		print(reactor)
	end
	--]]
	
end

-- Start the timer initially
find_all_reactors()





local function check_reactor()
	Timer.Wait(check_reactor, 2000) --recursively run again every X milliseconds

	--local components = blue_prints.most_recent_circuitbox.GetComponentString("CircuitBox").Components


	for _, reactor in pairs(listOfReactors) do
		local reactor_class = reactor.GetComponentString("Reactor")
		
		local last_user_was_player = reactor_class.LastUserWasPlayer
		local last_user_character = reactor_class.LastUser
		
		if last_user_was_player and last_user_character ~= nil then
			last_user_name = last_user_character.name
		else
			return
		end
		
		
		local target_fission_rate = reactor_class.TargetFissionRate
		local target_turbine_output = reactor_class.TargetTurbineOutput 
		
		if AntiGrief.shouldIgnoreThisPersonForAlarms(last_user_name) then return end
		
		local elapsed_time_since_last_alert = Timer.GetTime() - time_of_last_alert
		
		
		if target_fission_rate > 85 and target_turbine_output < 15 and AntiGrief.config.reactorAlarmEnabled and elapsed_time_since_last_alert > 30 then
			local message_to_broadcast = (last_user_name .. " has set the reactor to meltdown! Fission rate: " .. tostring(target_fission_rate) .. " Turbine output: " .. tostring(target_turbine_output))
			AntiGrief.activateAlarm(message_to_broadcast)
			time_of_last_alert = Timer.GetTime()
			return
		end
		
		--print(tostring(target_fission_rate))
		--print(tostring(target_turbine_output))
		
		
	end
	
end

-- Start the timer initially
check_reactor()