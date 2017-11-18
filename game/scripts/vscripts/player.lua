--CDOTA_PlayerResource:AddPlayerData("UnitKV", NETWORKVAR_TRANSMIT_STATE_PLAYER, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
local buildingShopData = table.deepcopy(BuildingKV:GetAllBuildings())
for k,v in pairs(LoadKeyValues("scripts/npc/frostivus_building_shop.txt")) do
  buildingShopData[k].Category = v.Category
  buildingShopData[k].BuildingID = v.BuildingID
  -- we dont net to network DynamicModels
end
for k, _ in pairs(buildingShopData) do
  buildingShopData[k].DynamicModels = nil
  buildingShopData[k].Spawner = nil
end
CDOTA_PlayerResource:AddPlayerData("BuildingShopKV", NETWORKVAR_TRANSMIT_STATE_PLAYER, buildingShopData)

CDOTA_PlayerResource:AddPlayerData("Lumber", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)

function CDOTA_PlayerResource:ModifyLumber(plyID, lumberChange)
  self:SetLumber(plyID, math.floor(math.clamp(self:GetLumber(plyID) + lumberChange, 0 ,self:GetLumberCapacity(plyID))))
end

function CDOTA_PlayerResource:ModifyGold(plyID, goldChange, bReliable)
  local hero = self:GetSelectedHeroEntity(plyID)
  if hero:GetGold() + goldChange > self:GetGoldCapacity(plyID) then
    goldChange = self:GetGoldCapacity(plyID) - hero:GetGold()
  end
  self:GetSelectedHeroEntity(plyID):ModifyGold(goldChange, true, DOTA_ModifyGold_Unspecified)
end

CDOTA_PlayerResource:AddPlayerData("LumberCapacity", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)
CDOTA_PlayerResource:AddPlayerData("GoldCapacity", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)

CDOTA_PlayerResource:AddPlayerData("BuildingList", NETWORKVAR_TRANSMIT_STATE_NONE, {})

function CDOTA_PlayerResource:SpawnBuilding(plyID, unitName, spawnTable, callback)
  -- RotatePreview
  local origin = GetGroundPosition(spawnTable.origin, nil)
  local building = BuildingKV:GetBuilding(unitName)
  if not building then return end
  local owner = spawnTable.owner or self:GetSelectedHeroEntity(plyID)
  local rotation = spawnTable.rotation or 0
  local randomAngles = spawnTable.randomAngles or building.RandomAngles
  local sizeX, sizeY = BuildingKV:GetSize(unitName)
  local isPVP = GM:IsPVP()
  local iIsPVP = isPVP and 1 or 0
  if (rotation / 90) % 2 == 1 then
    sizeX, sizeY = sizeY, sizeX
  end
  -- check once again if area blocked
  local areaBlocked = GridNav:IsAreaBlocked(origin, sizeX, sizeY)
  if not areaBlocked or spawnTable.force then
    -- block area
    local blockers = {}
    local gridPointer = Vector(origin.x - (sizeX / 2) * 64, origin.y + (sizeY / 2) * 64, origin.z)
    local initialY = gridPointer.y
    for x=1, sizeX / 2  do
      gridPointer.y = initialY
      gridPointer.x = gridPointer.x + 64
      for y=1, sizeY / 2 do
        gridPointer.y = gridPointer.y - 64
        local obstruction = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = gridPointer, block_fow = iIsPVP})
        table.insert(blockers, obstruction)
        gridPointer.y = gridPointer.y - 64
      end
      gridPointer.x = gridPointer.x + 64
    end
    -- spawnbuilding
    local time = spawnTable.animationTime or building.AnimationTime or 4
    local animDistance = 400
    if building.IsLookout then
      animDistance = animDistance + 220
      origin.z = origin.z + 220
    end
    local fps = 30
    local step = animDistance / (time * fps)
    local startOrigin = Vector(origin.x, origin.y, origin.z - animDistance)

    local lookoutSentry
    if building.IsLookout then
      lookoutSentry = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/props_structures/wooden_sentry_tower001.vmdl", origin = startOrigin, scale = 0.8})
    end

    CreateUnitByNameAsync(unitName, startOrigin, false, owner, owner, self:GetTeam(plyID), function(unit)
      unit:SetNeverMoveToClearSpace(true)
      table.insert(self:GetBuildingList(plyID), unit)
      table.insert(Entities:GetBuildingListRaw(), unit)
      if building.IsLookout then
        ApplyStun(unit, time)
        unit:AddNewModifier(unit, nil, "modifier_frostivus_lookout", {lookoutSentry = lookoutSentry:GetEntityIndex()})
      end

      if randomAngles then
        unit:SetAngles(0, rotation + RandomInt(0, 360), 0)
      else
        unit:SetAngles(0, rotation, 0)
      end
      unit:SetContextThink("SetControllableByPlayer", function()
        unit:SetControllableByPlayer(plyID, true)
      end, 0)

      local constructionParticle = ParticleManager:CreateParticle("particles/misc/building_animation_debris.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
      ParticleManager:SetParticleControl(constructionParticle, 0, unit:GetOrigin())
      unit:SetHealth(1)
      unit:SetOrigin(startOrigin)
      unit:SetContextThink("contructionThink", function()
        if math.abs(origin.z - unit:GetOrigin().z) <= step then
          unit:SetOrigin(origin)
          if lookoutSentry then
            lookoutSentry:SetOrigin(origin - Vector(0, 0, 220))
          end
          ParticleManager:DestroyParticle(constructionParticle, false)
          ParticleManager:ReleaseParticleIndex(constructionParticle)
          unit:OnConstructionCompleted()
          return
        end
        if unit:GetOrigin() ~= origin then
          unit:Heal(unit:GetMaxHealth() / (time * fps), unit)
          startOrigin.z = startOrigin.z + step
          unit:SetOrigin(startOrigin)
          if lookoutSentry then
            lookoutSentry:SetOrigin(startOrigin - Vector(0, 0, 220))
          end
          return 1/fps
        end
      end, 0)
      for _, psos in pairs(blockers) do
        if lookoutSentry then
          psos:SetParent(lookoutSentry, nil)
        else
          psos:SetParent(unit, nil)
        end
      end
      if callback then
        callback(unit)
      end
    end)
  end
end

function CDOTA_PlayerResource:FindBuildingByName(plyID, unitName)
  local buildingList = self:GetBuildingList(plyID)
  for k, unit in pairs(buildingList) do
    if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() then
      table.remove(buildingList, k)
    elseif string.match(unit:GetUnitName(), unitName) then
      return unit
    end
  end
end

function CDOTA_PlayerResource:FindAllBuildingsWithName(plyID, unitName)
  local units = {}
  local buildingList = self:GetBuildingList(plyID)
  for k, unit in pairs(buildingList) do
    if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() then
      table.remove(buildingList, k)
    elseif string.match(unit:GetUnitName(), unitName) then
      table.insert(units, unit)
    end
  end
  return units
end

function CDOTA_PlayerResource:GetPlayerColor(plyID)
  if plyID == 0 then
    return Vector(57, 107, 212)
  end
  if plyID == 1 then
    return Vector(109, 226, 176)
  end
  if plyID == 2 then
    return Vector(161, 12, 159)
  end
  if plyID == 3 then
    return Vector(219, 217, 46)
  end
  if plyID == 4 then
    return Vector(215, 106, 19)
  end
end


require "player_building"
require "player_persistence"
