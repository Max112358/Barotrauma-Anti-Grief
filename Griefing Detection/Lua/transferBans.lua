if CLIENT then return end --prevents it from running on the client

local personalBanListPath = path .. "/bannedplayers.txt"



-- Function to reduce points for all players
local function transfer()

	if File.Exists(personalBanListPath) then
		local bannedPlayerList = File.Read(personalBanListPath)
		
		local pattern = '(%b"")(.-)(%b"")(.-)(%b"")(.-)%s*/%s*>'
		
		
		if bannedPlayerList ~= "" then
			print("Transferring bans to bannedplayers.xml")
			print("---------------------")
		end

	for line in bannedPlayerList:gmatch("[^\n]+") do
		local name, _, reason, _, accountid = line:match(pattern)

		if name and reason and accountid then
			-- Remove the quotes from the captured values
			name = name:sub(2, -2)
			reason = reason:sub(2, -2)
			accountid = accountid:sub(2, -2)

			-- Print the extracted values
			
			print("Name: ", name)
			print("Reason: ", reason)
			print("Account ID: ", accountid)
			print("---------------------")
			
			local actualID = AccountId.Parse(accountid) --convert a string into an actual ID type
			Game.ServerSettings.BanList.BanPlayer(name, actualID, reason)
			
		else
			print("Invalid line format:", line)
		end
	end
	
	--delete the file as its no longer needed
	File.Write(personalBanListPath, "")
		
	else
		--do nothing
	end
end

local function delayedLaunch()
	Timer.Wait(transfer, 3000)
end

delayedLaunch() --start it the first time



	