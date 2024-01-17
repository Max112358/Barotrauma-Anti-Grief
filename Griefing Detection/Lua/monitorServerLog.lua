--this is a global so that all dependant classes can get it from here. Must be above the client filter!
messageFilters = {"wire", "undocked", "Fission"}

if CLIENT then return end -- stops this from running on the client


Hook.Add("serverLog", "checkForTrolling", function (text, serverLogMessageType)

	--1 is is the message type for item interaction, which includes the reactor and drone
	if serverLogMessageType == 1 then
		for key, client in pairs(Client.ClientList) do
			if client.HasPermission(ClientPermissions.Ban)then
			
				--detect putting the reactor into a dangerous state
				local pattern = "Fission rate: ([8-9]%d)"
				local pattern2 = "Fission rate: 100"
				local pattern3 = "Turbine output: ([0-1]?%d),"
				if (string.find(text, pattern) or string.find(text, pattern2)) and string.find(text, pattern3) then
					local chatMessage = ChatMessage.Create("Griefing Detection", text, ChatMessageType.Default, nil, nil)
					chatMessage.Color = Color(255, 255, 0, 255)
					Game.SendDirectChatMessage(chatMessage, client)
				end
				
				--detect undocking the drone or ship
				local undockPattern = "undocked"
				if string.find(text, undockPattern) then
					local chatMessage = ChatMessage.Create("Griefing Detection", text, ChatMessageType.Default, nil, nil)
					chatMessage.Color = Color(255, 255, 0, 255)
					Game.SendDirectChatMessage(chatMessage, client)
				end
				
			end
		end
	end

	--5 is is the message type for wiring
	if serverLogMessageType == 5 then
		for key, client in pairs(Client.ClientList) do
			if client.HasPermission(ClientPermissions.Ban)then
				local chatMessage = ChatMessage.Create("Griefing Detection", text, ChatMessageType.Default, nil, nil)
				chatMessage.Color = Color(255, 255, 0, 255)
				Game.SendDirectChatMessage(chatMessage, client)
			end
		end
	end
	
end)

