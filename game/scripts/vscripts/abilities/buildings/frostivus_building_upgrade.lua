local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

frostivus_building_upgrade = class({})

function frostivus_building_upgrade:OnSpellStart()
  local caster = self:GetCaster()
  for _, child in pairs(caster:GetChildren()) do
    if child:GetClassname() == "point_simple_obstruction" then
      child:RemoveSelf()
    end
  end
  PlayerResource:SpawnBuilding(caster:GetPlayerOwnerID(), BuildingKV:GetUpgradeName(caster:GetUnitName()), {origin = GetGroundPosition(caster:GetOrigin(), caster), rotation = caster:GetAngles().y, Force = true})
  caster:Kill(self, caster)
end
