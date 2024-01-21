

--the purpose of this script is to initalize the mod
--it reads any changes from the default config and saves the result as a global varible
--after that it loads the rest of the scripts


--get the local path and save it as a global. only autorun files can get the path in this way!
griefingDetectionPath = ...

local configPath = griefingDetectionPath .. "/config.json"
griefingDetectionConfig = dofile(griefingDetectionPath .. "/Lua/defaultConfig.lua") --config is also a global

if File.Exists(configPath) then
	local overrides = json.parse(File.Read(configPath))
	for i, _ in pairs(griefingDetectionConfig) do
		if overrides[i] ~= nil then
			griefingDetectionConfig[i] = overrides[i]
		end
	end
end

-- write the config back to disk to ensure it lists any new options
File.Write(configPath, json.serialize(griefingDetectionConfig))

--run the rest of the files
dofile(griefingDetectionPath .. "/Lua/monitorServerLog.lua")
dofile(griefingDetectionPath .. "/Lua/checkPlayerActions.lua")
dofile(griefingDetectionPath .. "/Lua/commands.lua")
dofile(griefingDetectionPath .. "/Lua/checkBanList.lua")
dofile(griefingDetectionPath .. "/Lua/recieveServerMessages.lua")
dofile(griefingDetectionPath .. "/Lua/transferBans.lua")
