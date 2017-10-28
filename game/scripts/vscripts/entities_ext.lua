CEntities.BuildingList = {}

function CEntities:GetBuildingListRaw()
  return self.BuildingList
end

-- all access on the global building list should be over this function to ensure the retunred building(s) are valid
function CEntities:GetAllBuildings()
  for k, unit in pairs(self.BuildingList) do
    if not IsValidEntity(unit) or not unit:IsAlive() then
      -- remove is costly but shouldnt happen to often
      table.remove(self.BuildingList, k)
    end
  end
  return self.BuildingList
end

function CEntities:FindBuildingByName(unitName)
  for _, bld in pairs(self:GetAllBuildings()) do
    if string.match(bld:GetUnitName(), unitName) then
      return bld
    end
  end
end

function CEntities:FindAllBuildingsWithName(unitName)
  local res = {}
  for _, bld in pairs(self:GetAllBuildings()) do
    if string.match(bld:GetUnitName(), unitName) then
      table.insert(res, bld)
    end
  end
  return res
end

function CEntities:GetRandomCloseBuildingWithName(center, unitName)
  local searchRadius = GameMode.BuildingRange * 5
  local acceptedRadius = 1000
  local res
  for _, bld in pairs(self:GetAllBuildings()) do
    if GridNav:CanFindPath(center, bld:GetOrigin()) and string.match(bld:GetUnitName(), unitName) then
      local dist = (bld:GetOrigin() - center):Length2D()
      if dist <= acceptedRadius and RandomInt(1, 3) == 1 then
        return bld
      end
      if dist < searchRadius then
        res = bld
        searchRadius = dist
      end
    end
  end
  return res
end

function CEntities:GetClosestFromTable(origin, tbl)
  local dist = -1
  local res
  for _, ent in pairs(tbl) do
    if dist == -1 or (origin - ent.GetOrigin()):Length2D() < dist then
      res = ent
    end
  end
  return res
end
