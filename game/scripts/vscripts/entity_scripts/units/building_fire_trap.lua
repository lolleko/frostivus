function Spawn(entityKV)
    thisEntity:SetContextThink("OrderThink", OrderThink, 0)
    BreatheFire = thisEntity:FindAbilityByName("frostivus_fire_trap_breathe_fire")
    BreatheFire:ToggleAutoCast()
end

function OrderThink()
    if BreatheFire:IsFullyCastable() and BreatheFire:GetAutoCastState() then
        local castRange = thisEntity:GetAttackRange()
        local units = FindUnitsInRadius(
            thisEntity:GetTeam(),
            thisEntity:GetOrigin(),
            nil,
            castRange,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        for k = #units, 1, - 1 do
            local unit = units[k]
            -- check if in front
            if (unit:GetOrigin() - thisEntity:GetOrigin()):Normalized():Dot(thisEntity:GetForwardVector()) < 0.2 then
                table.remove(units, k)
            end
        end

        if #units > 0 and IsValidEntity(units[1]) then
            thisEntity:CastAbilityOnPosition(units[1]:GetOrigin(), BreatheFire, - 1)
        end
    end

    return 1
end
