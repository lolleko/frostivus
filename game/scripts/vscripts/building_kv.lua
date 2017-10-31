-- Helper class for BuildingKV access
BuildingKV = class({})
BuildingKV.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

function BuildingKV:GetBuilding(name)
  local data = self.UnitKV[name]
  if istable(data) and data.Building then
    data.Building.Model = data.Model
    data.Building.ModelScale = data.ModelScale or 1
    return data.Building
  end
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
