function Spawn(entityKV)
    thisEntity:SetContextThink("OrderThink", OrderThink, 0)
    BreatheFire = thisEntity:FindAbilityByName("frostivus_fire_trap_breathe_fire")
end

function OrderThink()
    if BreatheFire:IsFullyCastable() then
      local castRange = BreatheFire:GetCastRange(Vector(), nil)
        local units =
            FindUnitsInRadius(
            thisEntity:GetTeam(),
            thisEntity:GetOrigin() + thisEntity:GetForwardVector() * (castRange / 2),
            nil,
            (castRange / 2),
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        if #units > 0 and IsValidEntity(units[1]) then
            thisEntity:CastAbilityOnTarget(units[1], BreatheFire, -1)
        end
    end

    return 1
end
