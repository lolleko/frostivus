local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

frostivus_building_upgrade = class({})

function frostivus_building_upgrade:OnSpellStart()
    local caster = self:GetCaster()
    local plyID = caster:GetPlayerOwnerID()
    local upgradeName = BuildingKV:GetUpgradeName(caster:GetUnitName())
    local upgradeRequirements = table.deepcopy(BuildingKV:GetRequirements(upgradeName))
    -- temporairly increase max count to allow upgrade
    -- TODO make this less hacky
    if upgradeRequirements.MaxAlive then
        upgradeRequirements.MaxAlive = upgradeRequirements.MaxAlive + 1
    end
    if PlayerResource:HasRequirements(plyID, upgradeRequirements, upgradeName) then
        PlayerResource:SpendResources(plyID, upgradeRequirements)
    else
        return
    end
    for _, child in pairs(caster:GetChildren()) do
        if child:GetClassname() == "point_simple_obstruction" then
            child:RemoveSelf()
        end
    end
    if caster.LookoutSentry then
        for _, child in pairs(caster.LookoutSentry:GetChildren()) do
            if child:GetClassname() == "point_simple_obstruction" then
                child:RemoveSelf()
            end
        end
    end
    PlayerResource:SpawnBuilding(
        plyID,
        BuildingKV:GetUpgradeName(caster:GetUnitName()),
        {origin = GetGroundPosition(caster:GetOrigin(), caster), rotation = caster:GetAngles().y, force = true}
    )
    caster:Kill(self, caster)
end
