local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
local abilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

frostivus_buy = class({})

--aliases
build_defense_wall = frostivus_buy
build_defense_catapult = frostivus_buy
build_defense_flame_thrower = frostivus_buy

function frostivus_buy:OnSpellStart()
  local instanceKV = abilityKV[self:GetAbilityName()]
  if instanceKV["Building"] then
    print("logging")
    local modelName = unitKV[instanceKV["UnitName"]].model
    local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelName, origin = caster:GetOrigin()})
    prop:AddEffects(EF_NODRAW)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(plyID), "buildingStartPreview", {previewModel = model:GetEntityIndex()})
  end
end
