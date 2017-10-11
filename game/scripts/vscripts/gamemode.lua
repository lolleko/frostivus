require "cgcore.gamemode"

require "events"

function GameMode:Init()
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 4)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_3, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_4, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_5, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_6, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_7, 0)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_8, 0)
end
