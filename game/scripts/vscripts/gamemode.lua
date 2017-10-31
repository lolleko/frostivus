require "cgcore.gamemode"

require "events"

function GameMode:Init()
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 4)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_3, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_4, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_5, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_6, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_7, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_8, 0)

	GameRules:GetGameModeEntity():SetAnnouncerDisabled( true )
	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled( true )

	GameRules:SetHeroSelectionTime( 30.0 )
	--GameRules:SetTimeOfDay( 0.25 )
	GameRules:SetStrategyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )
	GameRules:SetPreGameTime( 0.0 )
	GameRules:SetPostGameTime( 45.0 )
	GameRules:SetTreeRegrowTime( 10.0 )
	GameRules:SetStartingGold( 0 )
	GameRules:SetGoldTickTime( 999999.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetStartingGold( 0 )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled( false )
	GameRules:GetGameModeEntity():SetStashPurchasingDisabled( true )
	GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled( true )
	GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled( true )
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

function GameMode:GetDifficultyScalar()
	if not self.NextDifficultyCalculation or self.NextDifficultyCalculation <= GameRules:GetGameTime() then
		local scale = 1
		for _, bld in pairs(Entities:GetAllBuildings()) do
			local level = bld:GetLevel()
			scale = scale + level * 2
		end
		for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
			scale = scale + 60
			scale = scale + PlayerResource:GetSelectedHeroEntity(plyID):GetLevel() * 10
		end
		self.DifficultyScale = scale
		self.NextDifficultyCalculation = GameRules:GetGameTime() + 10
	end
	return self.DifficultyScale or 1
end

function GameMode:SetCoopSpiritTree(tree)
	if tree then
		self.coopSpiritTree = tree
	end
end

function GameMode:GetSpiritTree()
	if self:IsPVP() then
		return PlayerResource:FindBuildingByName(plyID, "npc_frostivus_spirit_tree_pvp")
	end
	return self.coopSpiritTree
end

function GameMode:GetBuildingCenter(plyID)
	return self:GetSpiritTree():GetOrigin()
end

function GameMode:GetBuildingRange(plyID)
	if self:IsPVP() then
		return 1280
	end
	return 2240
end
