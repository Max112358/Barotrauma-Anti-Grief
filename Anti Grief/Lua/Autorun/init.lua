

--the purpose of this script is to initalize the mod
--it reads any changes from the default config and saves the result as a global varible
--after that it loads the rest of the scripts

--type "cl_reloadlua" in the console to reload all scripts. This is way easier than restarting the game every time.

--get the local path and save it as a global. only autorun files can get the path in this way!
AntiGrief = {}
AntiGrief.path = ...

AntiGrief.configPath = AntiGrief.path .. "/config.json"
AntiGrief.config = dofile(AntiGrief.path .. "/Lua/defaultConfig.lua") --config is also a global

if CLIENT then 
	AntiGrief.sound = Game.SoundManager.LoadSound(AntiGrief.path .. "/alert.ogg") --this will crash if you run it server side
end 

if File.Exists(AntiGrief.configPath) then
	local overrides = json.parse(File.Read(AntiGrief.configPath))
	for i, _ in pairs(AntiGrief.config) do
		if overrides[i] ~= nil then
			AntiGrief.config[i] = overrides[i]
		end
	end
end

-- write the config back to disk to ensure it lists any new options
File.Write(AntiGrief.configPath, json.serialize(AntiGrief.config))

--run the rest of the files
dofile(AntiGrief.path .. "/Lua/utilities.lua")
dofile(AntiGrief.path .. "/Lua/checkPlayerActions.lua")
dofile(AntiGrief.path .. "/Lua/checkWiring.lua")
dofile(AntiGrief.path .. "/Lua/checkReactor.lua")
dofile(AntiGrief.path .. "/Lua/commands.lua")
dofile(AntiGrief.path .. "/Lua/checkBanList.lua")
dofile(AntiGrief.path .. "/Lua/transferBans.lua")
dofile(AntiGrief.path .. "/Lua/markDetonators.lua")
dofile(AntiGrief.path .. "/Lua/handleRoundEnd.lua")
dofile(AntiGrief.path .. "/Lua/monitorServerLog.lua") --these 2 have been replaced by patch hooks
dofile(AntiGrief.path .. "/Lua/recieveServerMessages.lua")