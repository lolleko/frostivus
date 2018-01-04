function Spawn(entityKV)
    thisEntity:SetContextThink("OrderThink", OrderThink, 0)
    thisEntity:AddNewModifier(thisEntity, nil, "modifier_frostivus_healer_heal_caster", {})

    HealAbility = thisEntity:FindAbilityByName("frostivus_healer_heal")
    HealAbility:ToggleAutoCast()
end

function OrderThink()
    if thisEntity:IsChanneling() then
        return 1
    end

    if HealAbility:IsFullyCastable() and HealAbility:GetAutoCastState() then
        local units =
            FindUnitsInRadius(
            thisEntity:GetTeam(),
            thisEntity:GetOrigin(),
            nil,
            HealAbility:GetCastRange(Vector(), nil),
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        for k = #units, 1, -1 do
            local unit = units[k]
            if unit:GetHealth() == unit:GetMaxHealth() then
                table.remove(units, k)
            end
        end

        if #units > 0 and IsValidEntity(units[1]) then
            thisEntity:CastAbilityOnTarget(units[1], HealAbility, -1)
        end
    end
    return 1
end
