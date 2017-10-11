--CDOTA_PlayerResource:AddPlayerData("UnitKV", NETWORKVAR_TRANSMIT_STATE_PLAYER, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
CDOTA_PlayerResource:AddPlayerData("InvestmentsKV", NETWORKVAR_TRANSMIT_STATE_PLAYER, LoadKeyValues("scripts/npc/frostivus_investments.txt"))

CDOTA_PlayerResource:AddPlayerData("Lumber", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)

require "player_investment"
