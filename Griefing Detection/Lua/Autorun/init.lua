
--get the local path and save it as a global. only autorun files can get the path in this way!
path = ...

local configPath = path .. "/config.json"
config = dofile(path .. "/Lua/defaultConfig.lua") --config is also a global

if File.Exists(configPath) then
	local overrides = json.parse(File.Read(configPath))
	for i, _ in pairs(config) do
		if overrides[i] ~= nil then
			config[i] = overrides[i]
		end
	end
end

-- write the config back to disk to ensure it lists any new options
File.Write(configPath, json.serialize(config))

--run the rest of the files
dofile(path .. "/Lua/serverSide.lua")
dofile(path .. "/Lua/clientSide.lua")
dofile(path .. "/Lua/commands.lua")
