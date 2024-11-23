if SERVER then return end --prevents it from running on the server




 --this needs to be debugged. im not sure its working.
--[[
Hook.Patch("Barotrauma.Items.Components.Connection", "DisconnectWire", function(instance, ptable)
	
	--print(tostring(instance.item))
	
	--print('‖color:red‖text I want to be red here‖end‖')
	--print('‖color:#ff0000‖text I want to be red here‖end‖')
	
	local panel_class = instance.item.GetComponentString("ConnectionPanel")
	
	print("panel_class.User " .. tostring(panel_class.User))
	if panel_class.User == nil then return end
	
	print("panel_class.AlwaysAllowRewiring " .. tostring(panel_class.AlwaysAllowRewiring))
	if panel_class.AlwaysAllowRewiring then return end --ignore wrecks and pirates, etc
	
	print("AntiGrief.shouldIgnoreThisPersonForAlarms(panel_class.User.name) " .. tostring(AntiGrief.shouldIgnoreThisPersonForAlarms(panel_class.User.name)))
	if AntiGrief.shouldIgnoreThisPersonForAlarms(panel_class.User.name) then return end
	print("AntiGrief.config.wiringAlarmEnabled " .. tostring(AntiGrief.config.wiringAlarmEnabled))
	if AntiGrief.config.wiringAlarmEnabled ~= true then return end
	
	local message_to_broadcast = panel_class.User.name .. " is changing wires inside " .. tostring(instance.item)
	AntiGrief.activateAlarm(message_to_broadcast)
	
end, Hook.HookMethodType.After)
--]]


--[[  --this does not work because you can only see your own client
Hook.Patch("Barotrauma.Items.Components.ConnectionPanel", "ClientEventWrite", function(instance, ptable)
	
	print("detected client event write")
	
	if instance.AlwaysAllowRewiring then return end --ignore wrecks and pirates, etc
	
	if instance.User == nil then return end
	if AntiGrief.shouldIgnoreThisPersonForAlarms(instance.User.name) then return end
	if AntiGrief.config.wiringAlarmEnabled ~= true then return end
	
	local message_to_broadcast = instance.User.name .. " is changing wires inside " .. tostring(instance.item)
	AntiGrief.activateAlarm(message_to_broadcast)
	
end, Hook.HookMethodType.After)
--]]




--Hook.Patch("Barotrauma.Items.Components.Wire", "UpdateEditing", {"System.Collections.Generic.List`1[[Barotrauma.Items.Components.Wire]]"}, function(instance, ptable)
--	print("wire was updated")
--end, Hook.HookMethodType.After)

--[[
local most_recent_panel_user = nil
local most_recent_time_wire_was_connected = Timer.GetTime()
local most_recent_time_panel_was_selected = Timer.GetTime()


local function report_wire_change(wasDisconnect, wire)

	--disconnects are always real
	--connects only do the first one, and only if select was not called recently
	if most_recent_panel_user == nil then return end
	
	
	
	AntiGrief.config = json.parse(File.Read(AntiGrief.configPath)) -- I have no idea why this is needed. Somehow its not recognizing changes to the global config without it. Reference error somehow?
	
	if AntiGrief.shouldIgnoreThisPersonForAlarms(most_recent_panel_user) then return end
	if AntiGrief.config.wiringAlarmEnabled ~= true then return end
	
	
	local message_to_broadcast = nil
	if wasDisconnect then
		message_to_broadcast = (most_recent_panel_user .. " disconnected " .. tostring(wire.Connections[1]))
	end
	
	
	--[[
	local message_to_broadcast = nil
	if wasDisconnect then
		message_to_broadcast = (most_recent_panel_user .. " disconnected " .. tostring(wire.Connections[1]))
	else
		local elapsed_time_connection = Timer.GetTime() - most_recent_time_wire_was_connected
		local elapsed_time_selected = Timer.GetTime() - most_recent_time_panel_was_selected
		if elapsed_time_connection > 3 and elapsed_time_selected > 3 then
			message_to_broadcast = (most_recent_panel_user .. " connected " .. tostring(wire.Connections[1]))
			most_recent_time_wire_was_connected = Timer.GetTime()
		end
	end
	--]]
	
	--[[
	if message_to_broadcast ~= nil then AntiGrief.activateAlarm(message_to_broadcast) return end

end
--]]


--[[  --this is causing problems. It keeps printing when people simply open a box.
Hook.Patch("Barotrauma.Items.Components.Connection", "ConnectWire", function(instance, ptable)
	--print("wire was connected")
	--print(instance)
	--print(ptable)
	--print(ptable["wire"])
	--print("I think that " .. most_recent_panel_user .. " changed the wire")
	--print(ptable["wire"].Connections[0]) --seems to be always nil
	
	--print(ptable["wire"].Connections[1])
	if ptable["wire"].Connections[1] ~= nil then
		report_wire_change(false, ptable["wire"])
	end
end, Hook.HookMethodType.After)
--]]



--[[
Hook.Patch("Barotrauma.Items.Components.Connection", "DisconnectWire", function(instance, ptable)
	--print("wire was disconnected")
	--print(instance)
	--print(ptable)
	--print(ptable["wire"])
	--print("I think that " .. most_recent_panel_user .. " changed the wire")
	--print(ptable["wire"].Connections[0])
	--print(ptable["wire"].Connections[1])
	--most_recent_time_panel_was_changed = Timer.GetTime()
	--print(most_recent_time_panel_was_changed)
	
	if ptable["wire"].Connections[1] ~= nil then
		report_wire_change(true, ptable["wire"])
	end
end, Hook.HookMethodType.After)



Hook.Patch("Barotrauma.Items.Components.ConnectionPanel", "Select", function(instance, ptable)
	--print("wire was disconnected")
	--print(instance)
	--print(ptable)
	--print(ptable["wire"])
	--print("I think that " .. most_recent_panel_user .. " changed the wire")
	--print(ptable["wire"].Connections[0])
	--print(ptable["wire"].Connections[1])
	--most_recent_time_panel_was_changed = Timer.GetTime()
	--print(most_recent_time_panel_was_changed)
	--print("select was run")
	--print(ptable["picker"].name)
	
	
	--if ptable["wire"].Connections[1] ~= nil then
	--	report_wire_change(true, ptable["wire"])
	--end
	
	
	if ptable["picker"] ~= nil then
		--print(ptable["character"])
		--print(ptable["character"].name)
		most_recent_panel_user = ptable["picker"].name
		most_recent_time_panel_was_selected = Timer.GetTime()
	end
end, Hook.HookMethodType.After)
--]]



