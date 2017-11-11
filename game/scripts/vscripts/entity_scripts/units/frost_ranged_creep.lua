function Spawn(entityKV)
  thisEntity:SetContextThink( "OrderThink", OrderThink, 0)
end

function OrderThink()
  local frostArmor = thisEntity:FindAbilityByName("ogre_magi_frost_armor")
  if frostArmor:IsFullyCastable() then
    local units = FindUnitsInRadius(
      thisEntity:GetTeam(),
      thisEntity:GetOrigin(),
      nil,
      frostArmor:GetCastRange(nil, nil),
      DOTA_UNIT_TARGET_TEAM_FRIENDLY,
      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      DOTA_UNIT_TARGET_FLAG_NONE,
      FIND_ANY_ORDER,
      false
    )
    for k, unit in pairs(units) do
      if unit:HasModifier("modifier_ogre_magi_frost_armor") then
        table.remove(units, k)
      end
    end
    if #units > 0 and IsValidEntity(units[1]) then
      thisEntity:CastAbilityOnTarget(units[1], frostArmor, - 1)
      ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
        Position = GM:GetSpiritTree():GetOrigin(),
        Queue = 1
      })
    end
  end

  return 1
end
