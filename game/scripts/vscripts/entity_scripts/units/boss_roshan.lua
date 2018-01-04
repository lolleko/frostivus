function Spawn(entityKV)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity:SetContextThink("OrderThink", OrderThink, 0)
    GM:ScaleUnit(thisEntity)
    SlamAbility = thisEntity:FindAbilityByName("frostivus_roshan_slam")
    FireBreathAbility = thisEntity:FindAbilityByName("frostivus_roshan_fire_breath")
end

function OrderThink()
    if thisEntity:IsChanneling() then
        return 1
    end

    if SlamAbility:IsCooldownReady() then
        local units =
            FindUnitsInRadius(
            thisEntity:GetTeam(),
            thisEntity:GetOrigin(),
            nil,
            SlamAbility:GetSpecialValueFor("radius"),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false
        )
        if #units > 0 and IsValidEntity(units[1]) then
            thisEntity:CastAbilityNoTarget(SlamAbility, -1)
            return 2
        end
    end

    if FireBreathAbility:IsCooldownReady() then
        local units =
            FindUnitsInRadius(
            thisEntity:GetTeam(),
            thisEntity:GetOrigin(),
            nil,
            FireBreathAbility:GetSpecialValueFor("distance"),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false
        )
        if #units > 0 and IsValidEntity(units[1]) then
            thisEntity:CastAbilityOnPosition(units[1]:GetOrigin(), FireBreathAbility, -1)
            return FireBreathAbility:GetChannelTime()
        end
    end

    -- second phase
    -- if we have no abilities to cast move towards tree
    if thisEntity:GetHealth() < thisEntity:GetMaxHealth() * 0.75 then
        local tree = GM:GetSpiritTree()
        -- if we are far away move closer
        if (thisEntity:GetOrigin() - tree:GetOrigin()):Length2D() >= GM:GetBuildingRange() / 2 * math.sqrt(2) then
            thisEntity:MoveToPosition(tree:GetOrigin())
            -- move for at least 7 seconds
            return 4
        else
            -- TODO add chance here to randomly bash down a building
            thisEntity:MoveToPositionAggressive(tree:GetOrigin())
            return 4
        end
    end

    return 1
end
