require "cgcore.util"

require "building_kv"


require "gamemode"

require "player"

require "quest"
require "quests"
require "quest_events"

require "building_grid"

--overrides
require "entities_ext"
require "base_npc_ext"
require "base_entity_ext"

-- GLOBAL CONFIG
require "precache"

-- GLOBAL modifiers
LinkLuaModifier("modifier_frostivus_resource_gather", "abilities/resources/modifier_frostivus_resource_gather.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frostivus_resource_carry", "abilities/resources/modifier_frostivus_resource_carry.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frostivus_lookout", "abilities/buildings/modifier_frostivus_lookout.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_provides_fow_position", "modifiers/modifier_provides_fow_position.lua", LUA_MODIFIER_MOTION_NONE)


GameMode.CGName = "frostivus"

if string.match(GetMapName(), "coop") then
	GameMode.bIsPVP = false
else
	GameMode.bIsPVP = true
end

if string.match(GetMapName(), "home") then
	GameMode.bIsPVPHome = true
else
	GameMode.bIsPVPHome = false
end

function GameMode:IsPVPHome()
	return self.bIsPVPHome
end

function GameMode:IsPVP()
	return self.bIsPVP
end

GameMode.CGDefaultData = {
	buildings = {},
	hero = {},
	newPlayer = true,
	activeQuests = {}
}

function Precache( context )
	GameRules.GameMode = GameMode()
	_G.GM = GameRules.GameMode

	GameRules.GameMode:Precache( context )
end

local json = require "cgcore.json"

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode:PreInit()
	--alias
	_G.GM = GameRules.GameMode
end
