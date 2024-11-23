

-- Function to activate the alarm
function AntiGrief.activateAlarm(printStatement)
	
	if Screen.Selected.Cam == nil then return end
	if AntiGrief.round_has_ended then return end
	
	print(printStatement)
	
	--find view position based on what you are looking at. This works even if you are dead/spectating.
	local centerX = Screen.Selected.Cam.Resolution.X / 2
	local centerY = Screen.Selected.Cam.Resolution.Y / 2
	local center = Vector2(centerX, centerY)
	local viewPosition = Screen.Selected.Cam.ScreenToWorld(center)
	
	local gain = AntiGrief.config.alarmVolume
	local range = 10000000
	AntiGrief.sound.Play(gain, range, viewPosition)
end



-- Function to find the AccountId id from a given character
function AntiGrief.getClientID(passedCharacter)
	local clientID = ""
	for key, client in pairs(Client.ClientList) do
		if client.Character == passedCharacter then
			clientID = client.AccountId
		end
	end
	return clientID
end


-- Function to find the AccountId id from a given character
function AntiGrief.getClientIDFromName(passedName)

	for key, client in pairs(Client.ClientList) do
		
		if client.Character ~= nil then
			if client.Character.name == passedName then
				return client.AccountId
			end
		end
		
		--a backup if someone is dead or spectating
		if client.Name == passedName then
			return client.AccountId
		end
	end
	return ""
end



-- Checks if a character has banpermission or not
function AntiGrief.isCharacterStringAnAdmin(passedCharacterString)
	if passedCharacterString == nil then return false end

	for key, client in pairs(Client.ClientList) do
		if client.HasPermission(ClientPermissions.Ban) and client.Character ~= nil then
			if tostring(client.Character.Name) == passedCharacterString then
				return true
			end
		end
	end
	return false
end


function AntiGrief.shouldIgnoreThisPersonForAlarms(passedCharacterString)
	if passedCharacterString == nil then return true end
	
	local isYou = false
	if Character.Controlled ~= nil then
		isYou = (Character.Controlled.name == passedCharacterString)
	end
	if (isYou and not AntiGrief.config.selfAlarmEnabled) then return true end --if its your character and self alarm not active, abort
	
	local isAdmin = AntiGrief.isCharacterStringAnAdmin(passedCharacterString)
	if isAdmin and not AntiGrief.config.adminAlarmEnabled then return true end --if its an admin character and admin alarm not active, abort


	return false
end





function AntiGrief.printAllClients()

	for key, client in pairs(Client.ClientList) do
		print ("------------")
		print ("client name: " .. tostring(client.Name))
		print ("client accountID: " .. tostring(client.AccountId))
		print ("client nameID: " .. tostring(client.NameId))
		print ("client steamID: " .. tostring(client.SteamID))
		if client.Character ~= nil then
			print ("client character name: " .. client.Character.name)
		else
			print ("client character not found (dead or spectating)")
		end
	end
end








