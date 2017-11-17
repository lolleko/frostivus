-- Helper class for BuildingKV access
BuildingKV = class({})
local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

BuildingKV.Buildings = {}

for name, data in pairs(unitKV) do
  if istable(data) and data.Building then
    -- track some data not in the building block but used by buildings
    data.Building.Model = data.Model
    data.Building.ModelScale = data.ModelScale or 1
    data.Building.StatusHealth = data.StatusHealth
    data.Building.ArmorPhysical = data.ArmorPhysical
    data.Building.AttackCapabilities = data.AttackCapabilities
    data.Building.StatusHealthRegen = data.StatusHealthRegen
    data.Building.Level = data.Level
    data.Building.AttackDamageMin = data.AttackDamageMin
    data.Building.AttackDamageMax = data.AttackDamageMax
    data.Building.AttackRate = data.AttackRate
    data.Building.AttackRange = data.AttackRange
    BuildingKV.Buildings[name] = data.Building
  end
end


-- DATA RETURNED FROM THIS CLASS SHOULD BE TREATED AS READONLY
-- DEEPCOPY THE RETURN VALUES IF YOU NEED TO CHANGE THEM
function BuildingKV:GetBuilding(name)
  return self.Buildings[name]
end

function BuildingKV:GetAllBuildings()
  return self.Buildings
end

function BuildingKV:GetSize(name)
  local bld = self:GetBuilding(name)
  if bld then
    return bld.SizeX, bld.SizeY
  end
end

function BuildingKV:GetUpgrade(name)
  local bld = self:GetBuilding(name)
  if bld then
    return bld.Upgrade
  end
end

function BuildingKV:GetRequirements(name)
  local bld = self:GetBuilding(name)
  if bld then
    return bld.Requirements
  end
end

function BuildingKV:GetUpgradeName(name)
  local bld = self:GetBuilding(name)
  if bld and bld.Upgrade then
    return bld.Upgrade.UnitName
  end
end
