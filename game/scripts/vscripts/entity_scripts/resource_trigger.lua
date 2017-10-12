function Spawn(entityKV)

end

function OnStartTouch(data)
  for k,v in pairs(data) do
    print(k, v)
  end
  print("test1")
  local donkey = data.activator
  if donkey:GetUnitName() == "npc_frostivus_lumber_drone" then
    donkey:AddNewModifier(donkey, nil, "modifier_frostivus_resource_carry", {IsLumber = true})
  elseif donkey:GetUnitName() == "npc_frostivus_gold_drone" then
    donkey:AddNewModifier(donkey, nil, "modifier_frostivus_resource_carry", {IsGold = true})
  end
end
