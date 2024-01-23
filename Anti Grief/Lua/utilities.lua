

-- Function to activate the alarm
function AntiGrief.activateAlarm(printStatement)
	print(printStatement)
	
	--find view position based on what you are looking at. This works even if you are dead/spectating.
	local centerX = Screen.Selected.Cam.Resolution.X / 2
	local centerY = Screen.Selected.Cam.Resolution.Y / 2
	local center = Vector2(centerX, centerY)
	local viewPosition = Screen.Selected.Cam.ScreenToWorld(center)
	
	local gain = 10
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
	local clientID = ""
	for key, client in pairs(Client.ClientList) do
		if client.Character ~= nil then
			if client.Character.name == passedName then
				clientID = client.AccountId
			end
		end
	end
	return clientID
end