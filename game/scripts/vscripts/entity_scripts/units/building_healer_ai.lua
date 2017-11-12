function Spawn(entityKV)
  thisEntity:SetContextThink( "OrderThink", OrderThink, 0)
  thisEntity:AddNewModifier(thisEntity, nil, "modifier_frostivus_healer_heal_caster", {})
end

function OrderThink()
  if thisEntity:IsChanneling() then return 1 end

  local heal = thisEntity:FindAbilityByName("frostivus_healer_heal")
  if heal:IsFullyCastable() and heal:GetAutoCastState() then
    local units = FindUnitsInRadius(
      thisEntity:GetTeam(),
      thisEntity:GetOrigin(),
      nil,
      heal:GetCastRange(Vector(), nil),
      DOTA_UNIT_TARGET_TEAM_FRIENDLY,
      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      DOTA_UNIT_TARGET_FLAG_NONE,
      FIND_ANY_ORDER,
      false
    )

    if #units > 0 and IsValidEntity(units[1]) then
      thisEntity:CastAbilityOnTarget(units[1], heal, -1)
    end
  end
  return 1
end
