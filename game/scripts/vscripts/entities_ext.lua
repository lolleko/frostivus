CEntities.BuildingList = {}

function CEntities:GetBuildingListRaw()
  return self.BuildingList
end

-- all access on the global building list should be over this function to ensure the retunred building(s) are valid
function CEntities:GetAllBuildings()
  for k, unit in pairs(self.BuildingList) do
    if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() then
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

FROSTIVUS_BUILDING_NONE = 0
FROSTIVUS_BUILDING_DEFENSE = 1
FROSTIVUS_BUILDING_LOOKOUT = 2
FROSTIVUS_BUILDING_WALL = 4
FROSTIVUS_BUILDING_LAST = 4

-- this hopefully performs better than FindUnitsInRadius
-- Basically O(2n) but very few distance calculations
function CEntities:FindBuildingInRadius(center, team, radius, buildingFlags)
  local res = {}
  for _, bld in pairs(self:GetAllBuildings()) do
    if not team or bld:GetTeam() == team or team == DOTA_TEAM_NOTEAM then
      local flags = false
      if not buildingFlags then
        flags = true
      end
      if not flags and (bit.band(buildingFlags, FROSTIVUS_BUILDING_DEFENSE) ~= 0 and bld:IsDefense()) then
        flags = true
      end
      if not flags and (bit.band(buildingFlags, FROSTIVUS_BUILDING_LOOKOUT) ~= 0 and bld:IsLookout()) then
        flags = true
      end
      if not flags and (bit.band(buildingFlags, FROSTIVUS_BUILDING_WALL) ~= 0 and bld:IsWall()) then
        flags = true
      end
      if flags and (bld:GetOrigin() - center):Length2D() <= radius then
        table.insert(res, bld)
      end
    end
  end
  return res
end
