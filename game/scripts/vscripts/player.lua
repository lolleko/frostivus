--CDOTA_PlayerResource:AddPlayerData("UnitKV", NETWORKVAR_TRANSMIT_STATE_PLAYER, LoadKeyValues("scripts/npc/npc_units_custom.txt"))
CDOTA_PlayerResource:AddPlayerData("InvestmentsKV", NETWORKVAR_TRANSMIT_STATE_PLAYER, LoadKeyValues("scripts/npc/frostivus_investments.txt"))

CDOTA_PlayerResource:AddPlayerData("Lumber", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)

function CDOTA_PlayerResource:ModifyLumber(plyID, lumberChange)
  self:SetLumber(plyID, self:GetLumber(plyID) + lumberChange)
end

CDOTA_PlayerResource:AddPlayerData("LumberCapacity", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)
CDOTA_PlayerResource:AddPlayerData("GoldCapacity", NETWORKVAR_TRANSMIT_STATE_PLAYER, 0)

CDOTA_PlayerResource:AddPlayerData("BuildingList", NETWORKVAR_TRANSMIT_STATE_NONE, {})

function CDOTA_PlayerResource:SpawnBuilding(plyID, unitName, spawnTable, callback)
  -- RotatePreview
  local origin = spawnTable.origin
  local owner = spawnTable.owner or self:GetSelectedHeroEntity(plyID)
  local rotation = spawnTable.rotation or 0
  local sizeX, sizeY
  if (rotation / 90) % 2 == 1 then
    sizeX, sizeY = spawnTable.sizeY, spawnTable.sizeX
  else
    sizeX, sizeY = spawnTable.sizeX, spawnTable.sizeY
  end
  -- check once again if area blocked
  local areaBlocked = GridNav:IsAreaBlocked(origin, sizeX, sizeY)
  if not areaBlocked then
    -- block area
    local gridPointer = Vector(origin.x - (sizeX / 2) * 64, origin.y + (sizeY / 2) * 64, origin.z)
    local initialY = gridPointer.y
    for x=1, sizeX / 2  do
      gridPointer.y = initialY
      gridPointer.x = gridPointer.x + 64
      for y=1, sizeY / 2 do
        gridPointer.y = gridPointer.y - 64
        SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = gridPointer})
        gridPointer.y = gridPointer.y - 64
      end
      gridPointer.x = gridPointer.x + 64
    end
    -- spawnbuilding
    local time = spawnTable.AnimationTime or 4
    local animDistance = 400
    local fps = 30
    local step = animDistance / (time * fps)
    local startOrigin = Vector(origin.x, origin.y, origin.z - animDistance)
    CreateUnitByNameAsync(unitName, startOrigin, false, owner, owner, self:GetTeam(plyID), function(building)
      table.insert(self:GetBuildingList(plyID), building)
      if randomAngles then
        building:SetAngles(0, RandomInt(0, 360), 0)
      else
        building:SetAngles(0, rotation, 0)
      end
      building:SetContextThink("SetControllableByPlayer", function()
        building:SetControllableByPlayer(plyID, true)
      end, 0)

      local constructionParticle = ParticleManager:CreateParticle("particles/misc/building_animation_debris.vpcf", PATTACH_ABSORIGIN_FOLLOW, building)
      ParticleManager:SetParticleControl(constructionParticle, 0, building:GetOrigin())
      building:SetHealth(1)
      building:SetOrigin(startOrigin)
      building:SetContextThink("contructionThink", function()
        if math.abs(origin.z - building:GetOrigin().z) <= step then
          building:SetOrigin(origin)
          ParticleManager:DestroyParticle(constructionParticle, false)
          ParticleManager:ReleaseParticleIndex(constructionParticle)
          building:OnConstructionCompleted()
          return
        end
        if building:GetOrigin() ~= origin then
          building:Heal(building:GetMaxHealth() / (time * fps), building)
          startOrigin.z = startOrigin.z + step
          building:SetOrigin(startOrigin)
          return 1/fps
        end
      end, 0)
      if callback then
        callback(building)
      end
    end)
  end
end

function CDOTA_PlayerResource:FindBuildingByName(plyID, unitName)
  local buildingList = self:GetBuildingList(plyID)
  for k, unit in pairs(buildingList) do
    if not IsValidEntity(unit) or not unit:IsAlive() then
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
    if not IsValidEntity(unit) or not unit:IsAlive() then
      table.remove(buildingList, k)
    elseif string.match(unit:GetUnitName(), unitName) then
      table.insert(units, unit)
    end
  end
  return units
end


require "player_investment"
