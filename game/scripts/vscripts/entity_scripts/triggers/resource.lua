function Spawn(entityKV)
  AddSpawnProperty(thisEntity, "IsGold", "bool", false, entityKV)
  AddSpawnProperty(thisEntity, "IsLumber", "bool", false, entityKV)
end

function OnStartTouch(data)
  local donkey = data.activator
  -- dirty string comparissons TODO performance?
  if thisEntity.IsLumber and donkey:GetUnitName() == "npc_frostivus_lumber_drone" or donkey:GetUnitName() == "npc_frostivus_lumber_drone_flying" then
    donkey:AddNewModifier(donkey, nil, "modifier_frostivus_resource_carry", {IsLumber = true})
  elseif thisEntity.IsGold and donkey:GetUnitName() == "npc_frostivus_gold_drone" or donkey:GetUnitName() == "npc_frostivus_gold_drone_flying" then
    donkey:AddNewModifier(donkey, nil, "modifier_frostivus_resource_carry", {IsGold = true})
  end
end
