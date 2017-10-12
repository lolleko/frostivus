require "cgcore.util"

require "gamemode"

require "player"

require "building_grid"

--overrides
require "base_npc_ext"
require "base_entity_ext"

-- GLOBAL CONFIG
require "precache"

-- GLOBAL modifiers
LinkLuaModifier("modifier_frostivus_resource_carry", "abilities/resources/modifier_frostivus_resource_carry.lua", LUA_MODIFIER_MOTION_NONE)

GameMode.CGName = "frostivus"

GameMode.CGDefaultData = {
	units = {}
}

function Precache( context )
	GameRules.GameMode = GameMode()

	GameRules.GameMode:Precache( context )
end

local json = require "cgcore.json"

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode:PreInit()
	--alias
	_G.GM = GameRules.GameMode
end
