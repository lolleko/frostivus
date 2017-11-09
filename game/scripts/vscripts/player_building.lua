local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
CDOTA_PlayerResource:AddPlayerData("PreviewModel", NETWORKVAR_TRANSMIT_STATE_NONE, nil)

function CDOTA_PlayerResource:HasRequirements(plyID, requirements)
  if requirements.Stage and requirements.Stage > GM:GetStage() then
    self:SendCastError(plyID, "frostivus_hud_error_stage_not_unlocked")
    return false
  end
  if requirements.LumberCost and self:GetLumber(plyID) < requirements.LumberCost then
    self:SendCastError(plyID, "frostivus_hud_error_not_enough_lumber")
    return false
  end
  if requirements.GoldCost and self:GetGold(plyID) < requirements.GoldCost then
    self:SendCastError(plyID, "frostivus_hud_error_not_enough_gold")
    return false
  end
  return true
end

function CDOTA_PlayerResource:SpendResources(plyID, requirements)
  if requirements.LumberCost then
    PlayerResource:ModifyLumber(plyID, -requirements.LumberCost)
  end
  if requirements.GoldCost  then
    PlayerResource:ModifyGold(plyID, -requirements.GoldCost, false)
  end
end

function CDOTA_PlayerResource:ProcessBuildingPreviewRequest(eventSourceIndex, data)
  local plyID = data.PlayerID
  local building = BuildingKV:GetBuilding(data.unitName)
  if not self:HasRequirements(plyID, building.Requirements) then
    return
  end
  local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = building.Model, scale = building.ModelScale})
  prop:AddEffects(EF_NODRAW)
  self:SetPreviewModel(plyID, prop)
  local range = GM:GetBuildingRange()
  local gridPointer = Vector(-range, range, 0)
  local groundHeight = GetGroundHeight(GM:GetBuildingCenter(plyID), prop)
  local blockedSquares = {}
  for x=-range,range,64  do
    for y=range,-range,-64  do
      local squarePos = Vector(x - 32, y -32, groundHeight)
      if GridNav:IsBlocked(squarePos) then
        table.insert(blockedSquares, squarePos)
      end
    end
  end
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(plyID), "buildingStartPreview", {
    buildingName = data.unitName,
    previewModel = prop:GetEntityIndex(),
    sizeX = building.SizeX,
    sizeY = building.SizeY,
    scale = building.ModelScale,
    center = GM:GetBuildingCenter(plyID),
    range = range,
    blockedSquares = blockedSquares
  })
end
CustomGameEventManager:RegisterListener("buildingPreviewRequest", function(...) PlayerResource:ProcessBuildingPreviewRequest(...) end)


function CDOTA_PlayerResource:ProcessConstructionRequest(eventSourceIndex, data)
  local plyID = data.PlayerID
  -- if shift is pressed dont delete preview
  if data.queue then
    local previewModel = self:GetPreviewModel(plyID)
    if IsValidEntity(previewModel) then
      previewModel:RemoveSelf()
    end
  end
  -- dont process canceld request jsut remove the model
  if data.cancel then return end

  -- check and create building
  local building = BuildingKV:GetBuilding(data.buildingName)
  if self:HasRequirements(plyID, building.Requirements) then
    self:SpendResources(plyID, building.Requirements)
    local origin = Vector(data.origin["0"], data.origin["1"], data.origin["2"])
    origin = GetGroundPosition(origin, nil)
    local sizeX, sizeY = building.SizeX, building.SizeY
    local randomAngles = building.RandomAngles
    self:SpawnBuilding(plyID, data.buildingName, {origin = origin, sizeX = sizeX, sizeY = sizeY, rotation = data.rotation, randomAngles = randomAngles})
  end

end
CustomGameEventManager:RegisterListener("buildingRequestConstruction", function(...) PlayerResource:ProcessConstructionRequest(...) end)

function CDOTA_PlayerResource:OnBuildingCheckArea(eventSourceIndex, data)
  local plyID = data.PlayerID
  local origin = Vector(data.origin["0"], data.origin["1"], data.origin["2"])
  local sizeX, sizeY = data.sizeX, data.sizeY

  local areaBlocked = not GridNav:IsPositionInSquare(GM:GetBuildingCenter(data.PlayerID), data.range, origin, sizeX, sizeY) or GridNav:IsAreaBlocked(origin, sizeX, sizeY)
  local previewModel = self:GetPreviewModel(plyID)
  -- sadly we have to rotate serverside
  -- since i failed to map rotation to the particle clientside
  if IsValidEntity(previewModel) then
    previewModel:SetAngles(0, data.rotation, 0)
  end
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "buildingUpdatePreview", {blocked = areaBlocked})
end
CustomGameEventManager:RegisterListener("buildingCheckArea", function(...) PlayerResource:OnBuildingCheckArea(...) end)

function CDOTA_PlayerResource:OnBuildingCheckSquare(eventSourceIndex, data)
  local origin = Vector(data.origin["0"], data.origin["1"], data.origin["2"])
  local squareID = data.squareID
  local areaBlocked = GridNav:IsBlocked(origin) or not GridNav:IsTraversable(origin)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(data.PlayerID), "buildingUpdateSquare", {blocked = areaBlocked, squareID = squareID})
end
CustomGameEventManager:RegisterListener("buildingCheckSquare", function(...) PlayerResource:OnBuildingCheckSquare(...) end)
