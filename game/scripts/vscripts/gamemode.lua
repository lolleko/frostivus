require "cgcore.gamemode"

require "events"

-- START MAP CONFIG
-- This part needs to be run first because it is required by other classes to setup the rule
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

GameMode.TeamMaxPlayersMap = {
	frost_tribes_coop = {
		[DOTA_TEAM_BADGUYS] = 0,
		[DOTA_TEAM_GOODGUYS] = 4
	},
	frost_tribes_pvp_home = {
		[DOTA_TEAM_BADGUYS] = 0,
		[DOTA_TEAM_GOODGUYS] = 1
	},
	frost_tribes_pvp_1v1 = {
		[DOTA_TEAM_BADGUYS] = 1,
		[DOTA_TEAM_GOODGUYS] = 1
	}
}
-- END MAP CONFIG


function GameMode:Init()
	for teamID, plyCount in pairs(self.TeamMaxPlayersMap[GetMapName()]) do
		GameRules:SetCustomGameTeamMaxPlayers(teamID, plyCount)

	end

	GameRules:GetGameModeEntity():SetAnnouncerDisabled( true )
	if not self:IsPVP() then
		GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled( true )
	end

	GameRules:SetHeroSelectionTime( 30.0 )
	--GameRules:SetTimeOfDay( 0.25 )
	GameRules:SetStrategyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetPreGameTime( 5.0 )
	GameRules:SetPostGameTime( 45.0 )
	GameRules:SetTreeRegrowTime( 10.0 )
	GameRules:SetStartingGold( 0 )
	GameRules:SetGoldTickTime( 999999.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetStartingGold( 0 )
	--GameRules:SetUseUniversalShopMode(true)
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled( false )
	GameRules:GetGameModeEntity():SetStashPurchasingDisabled( true )
	--GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled( true )
	--GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled( true )
	GameRules:GetGameModeEntity():SetBuybackEnabled(false)
	GameRules:GetGameModeEntity():DisableHudFlip( true )
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( true )
	GameRules:GetGameModeEntity():SetFriendlyBuildingMoveToEnabled( true )
	GameRules:GetGameModeEntity():SetDeathOverlayDisabled( true )
	GameRules:GetGameModeEntity():SetHudCombatEventsDisabled( true )
	GameRules:GetGameModeEntity():SetWeatherEffectsDisabled( true )
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	--GameRules:GetGameModeEntity():SetCustomTerrainWeatherEffect("particles/rain_fx/econ_snow.vpcf")
	GameRules:GetGameModeEntity():SetCameraSmoothCountOverride( 2 )
	GameRules:GetGameModeEntity():SetSelectionGoldPenaltyEnabled( false )
	GameRules:SetCustomGameAllowHeroPickMusic( false )
	GameRules:SetCustomGameAllowBattleMusic( false )
	GameRules:SetCustomGameAllowMusicAtGameStart( true )
end

function GameMode:GetDifficultyScalar(teamID)
	if not self.NextDifficultyCalculation or self.NextDifficultyCalculation <= GameRules:GetGameTime() then
		local scale = 1
		for _, bld in pairs(Entities:GetAllBuildings()) do
			if IsValidEntity(bld) and (not teamID or bld:GetTeam() == teamID) then
				local level = bld:GetLevel()
				scale = scale + level * 5
			end
		end
		for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
			if PlayerResource:HasSelectedHero(plyID) and (not teamID or PlayerResource:GetTeam(plyID) == teamID) then
				scale = scale + 140
				scale = scale + PlayerResource:GetSelectedHeroEntity(plyID):GetLevel() * 14
			end
		end
		scale = scale + self:GetStage() * 200
		self.DifficultyScale = scale
		self.NextDifficultyCalculation = GameRules:GetGameTime() + 10
	end
	return self.DifficultyScale or 1
end

function GameMode:ScaleUnit(unit)
	local scalar = self:GetDifficultyScalar(unit:GetOpposingTeamNumber())
	unit:SetMaxHealth(unit:GetMaxHealth() + math.floor(unit:GetMaxHealth() * scalar/800))
	unit:SetHealth(unit:GetMaxHealth())
	unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorValue() + (unit:GetPhysicalArmorValue() * scalar/1000))
	unit:SetBaseMagicalResistanceValue(unit:GetBaseMagicalResistanceValue() + (unit:GetBaseMagicalResistanceValue() * scalar/1000))
	unit:SetBaseDamageMin(unit:GetBaseDamageMin() + math.floor(scalar/80))
	unit:SetBaseDamageMax(unit:GetBaseDamageMax() + math.floor(scalar/80))
end

function GameMode:SetCoopSpiritTree(tree)
	if tree then
		self.coopSpiritTree = tree
	end
end

function GameMode:GetSpiritTree(plyID)
	if self:IsPVP() then
		if plyID then
			return PlayerResource:FindBuildingByName(plyID, "npc_frostivus_spirit_tree_pvp")
		else
			local trees = Entities:FindAllBuildingsWithName("npc_frostivus_spirit_tree")
			table.shuffle(trees)
			if #trees > 0 then
				return trees[1]
			end
		end
	end
	return self.coopSpiritTree
end

function GameMode:GetBuildingCenter(plyID)
	return self:GetSpiritTree(plyID):GetOrigin()
end

function GameMode:GetBuildingRange(plyID)
	if self:IsPVP() then
		return 1664
	end
	return 2432
end

function GameMode:GetStage(plyID)
	if plyID then
		return PlayerResource:GetStage(plyID)
	end
  return self.stage or 0
end

CDOTA_PlayerResource:AddPlayerData("GameStage", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)

function GameMode:SetStage(stage)
  self.stage  = stage
	-- we use playerdata to sync the stage to the client
	-- this will ensure the stage stil exists after a reconect
	for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
		PlayerResource:SetGameStage(plyID, stage)
	end
end
