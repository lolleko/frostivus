local investmentsKV = LoadKeyValues("scripts/npc/frostivus_investments.txt")
local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
CDOTA_PlayerResource:AddPlayerData("PreviewModel", NETWORKVAR_TRANSMIT_STATE_NONE, nil)

function CDOTA_PlayerResource:HasInvestmentRequirements(plyID, investmentName)
  -- for debuggin retru ntru for now
 --[[  local investment = investmentsKV[investmentName]
  if investment.LumberCost and not self:GetLumber(plyID) <= investment.LumberCost then
    return false
  end
  if investment.GoldCost and not self:GetGold(plyID) <= investment.GoldCost then
    return false
  end--]]
  return true
end

function CDOTA_PlayerResource:ProcessInvestmentRequest(eventSourceIndex, data)
  local plyID = data.PlayerID
  local investmentName = data.investmentName
  local investment = investmentsKV[investmentName]
  local unit = unitKV[investment["UnitName"]]
  if investment.Building then
    local modelName = unit.Model
    local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelName, scale = unit.ModelScale})
    prop:AddEffects(EF_NODRAW)
    self:SetPreviewModel(plyID, prop)
    local range = GameMode.BuildingRange
    local gridPointer = Vector(-range, range, 0)
    local groundHeight = GetGroundHeight(Vector(0,0,0), prop)
    local blockedSquares = {}
    for x=-1280,1280,64  do
      for y=1280,-1280,-64  do
        local squarePos = Vector(x - 32, y -32, groundHeight)
        if GridNav:IsBlocked(squarePos) then
          table.insert(blockedSquares, squarePos)
        end
      end
    end
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(plyID), "buildingStartPreview", {
      investmentName = investmentName,
      previewModel = prop:GetEntityIndex(),
      sizeX = unit.BuildingSizeX,
      sizeY = unit.BuildingSizeY,
      scale = unit.ModelScale,
      center = self:FindBuildingByName(plyID, "npc_frostivus_spirit_tree"):GetOrigin(),
      range = range,
      blockedSquares = blockedSquares
    })

  end
end
CustomGameEventManager:RegisterListener("investmentRequest", function(...) PlayerResource:ProcessInvestmentRequest(...) end)


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

  local investmentName = data.investmentName
  -- dota check and create building
  if self:HasInvestmentRequirements(plyID, investmentName) then
    local origin = Vector(data.origin["0"], data.origin["1"], data.origin["2"])
    local investment = investmentsKV[investmentName]
    local unit = unitKV[investment["UnitName"]]
    local sizeX, sizeY = unit.BuildingSizeX, unit.BuildingSizeY
    local randomAngles = unit.BuildingRandomAngles
    self:SpawnBuilding(plyID, investment.UnitName, {origin = origin, sizeX = sizeX, sizeY = sizeY, rotation = data.rotation, randomAngles = randomAngles})
  end

end
CustomGameEventManager:RegisterListener("buildingRequestConstruction", function(...) PlayerResource:ProcessConstructionRequest(...) end)

function CDOTA_PlayerResource:OnBuildingCheckArea(eventSourceIndex, data)
  local plyID = data.PlayerID
  local origin = Vector(data.origin["0"], data.origin["1"], data.origin["2"])
  local sizeX, sizeY = data.sizeX, data.sizeY

  local areaBlocked = not GridNav:IsPositionInSquare(self:FindBuildingByName(plyID, "npc_frostivus_spirit_tree"):GetOrigin(), data.range, origin, sizeX, sizeY) or GridNav:IsAreaBlocked(origin, sizeX, sizeY)
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
