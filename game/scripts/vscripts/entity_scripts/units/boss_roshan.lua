function Spawn(entityKV)
  thisEntity:SetContextThink( "OrderThink", OrderThink, 0)
  thisEntity.globalCooldown = 0
end

function OrderThink()

  if thisEntity:IsChanneling() then return 1 end

  local slam = thisEntity:FindAbilityByName("frostivus_roshan_slam")
  if slam:IsCooldownReady() and GameRules:GetGameTime() > thisEntity.globalCooldown then
    local units = FindUnitsInRadius(
        thisEntity:GetTeam(),
        thisEntity:GetOrigin(),
        nil,
        slam:GetSpecialValueFor("radius"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    if #units > 0 and IsValidEntity(units[1]) then
      thisEntity:CastAbilityNoTarget(slam, -1)
      thisEntity.globalCooldown = GameRules:GetGameTime() + 2
    end
  end

  local fireBreath = thisEntity:FindAbilityByName("frostivus_roshan_fire_breath")
  if fireBreath:IsCooldownReady() and GameRules:GetGameTime() > thisEntity.globalCooldown then
    local units = FindUnitsInRadius(
        thisEntity:GetTeam(),
        thisEntity:GetOrigin(),
        nil,
        fireBreath:GetSpecialValueFor("distance"),
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    if #units > 0 and IsValidEntity(units[1]) then
      thisEntity:CastAbilityOnPosition(units[1]:GetOrigin(), fireBreath, -1)
      thisEntity.globalCooldown = GameRules:GetGameTime() + 4
    end
  end

  -- second phase
  if thisEntity:GetHealth() < thisEntity:GetMaxHealth() * 0.75 and GameRules:GetGameTime() > thisEntity.globalCooldown then
    local tree = GM:GetSpiritTree()
    -- if we are far away move closer
    if tree:GetOrigin():Length2D(thisEntity:GetOrigin()) >= GM:GetBuildingRange() * math.sqrt(2) then
      thisEntity:MoveToPosition(tree:GetOrigin())
      -- move for at least 7 seconds
      thisEntity.globalCooldown = GameRules:GetGameTime() + 7
    else
      -- TODO add chance here to ranomly bash down a building
      thisEntity:MoveToPositionAggressive(tree:GetOrigin())
      thisEntity.globalCooldown = GameRules:GetGameTime() + 10
    end
  end

  return 1
end
