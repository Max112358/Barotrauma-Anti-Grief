if SERVER then return end --prevents it from running on the server

--the purpose of this script is check joining players against your local banlist and warn them if they are
--this way you can warn the host even if its not your server

local badGuyList = File.Read("Data/bannedplayers.xml")

Hook.Add("character.created", "checkNewGuyVsBanListOnCreation", function (createdCharacter)
	
	local clientID = AntiGrief.getClientID(createdCharacter)
	
	if (string.find(badGuyList, tostring(clientID))) and clientID ~= "" then
		local warningMessage = ("Spawn warning! " .. createdCharacter.name .. " is on your ban list!"  .. " Client ID: " .. tostring(clientID))
		AntiGrief.activateAlarm(warningMessage)
	end
	
end)