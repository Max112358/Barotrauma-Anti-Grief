
if SERVER then return end --prevents it from running on the server
--this script runs client side only. clients cannot see the serverLog, so cannot detect wiring issues or the reactor



local badGuyList = File.Read("Data/bannedplayers.xml")
--print(badGuyList)

local sound = Game.SoundManager.LoadSound(path .. "/alert.ogg")

-- Function to find the AccountId id from a given character
local function getClientID(passedCharacter)
	local clientID = ""
	for key, client in pairs(Client.ClientList) do
		if client.Character == passedCharacter then
			clientID = client.AccountId
		end
	end
	return clientID
end




Hook.Add("character.created", "checkNewGuyVsBanListOnCreation", function (createdCharacter)
	
	local clientID = getClientID(createdCharacter)
	--print("ID of new character: " .. tostring(clientID))
	
	if (string.find(badGuyList, tostring(clientID))) and clientID ~= "" then
		print("Spawn warning! " .. createdCharacter.name .. " is on your ban list!"  .. " Client ID: " .. tostring(clientID))
		sound.Play(10, 100000, Character.Controlled)
	end
	
end)