
--the purpose of this script is to provide a baseline set of values for the in game options
--the player can type gd reset to set all options to these values

local config = {}

config.susThreshold = 20 --tolerance for how suspicious someone can act before alarms go off
config.decayTime = 5000 --time until everyone loses a susPoint, in milliseconds
config.alarmVolume = 0.5 --how loud the alarm plays

config.wiringAlarmEnabled = true --controls the wiring alarm
config.undockAlarmEnabled = true --controls the dock alarm
config.reactorAlarmEnabled = true --controls the reactor alarm
config.selfAlarmEnabled = false --alarms will sound for your own actions
config.markDetonatorsEnabled = true --draw a target around detonators
config.adminAlarmEnabled = false --alarms will sound for the actions of anyone with ban permission

config.susTable = {}
config.susTable = { --how suspicious using a given item is
    ["fentanyl"] = 11,
    ["morphine"] = 4,
    ["opium"] = 3,
    ["fuelrod"] = 11,
    ["thoriumfuelrod"] = 11,
    ["rum"] = 11,
    ["ethanol"] = 8,
    ["calyxanide"] = 11,
	["flashpowder"] = 11,
	
	
	--ultra sus items beyond this point
	["deliriumine"] = 25,
	["huskeggs"] = 25,      --calyx extract
	["cyanide"] = 25,
	["radiotoxin"] = 25,
	["sufforin"] = 25,
	["paralyzant"] = 25,
	["chloralhydrate"] = 25,
	["morbusine"] = 25,
	["detonator"] = 25,
	["nitroglycerin"] = 25,
	["incendiumgrenade"] = 25,
	["fraggrenade"] = 25,
	["stungrenade"] = 25,
	["empgrenade"] = 25,
	["oxygeniteshard"] = 25,
	["nuclearshell"] = 25,
	["volatilecompoundn"] = 25,
	["molotovcoctail"] = 25
}


return config