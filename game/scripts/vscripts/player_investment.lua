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
  if investment.Building then
    local modelName = unitKV[investment["UnitName"]].Model
    local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = modelName})
    prop:AddEffects(EF_NODRAW)
    self:SetPreviewModel(plyID, prop)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(plyID), "buildingStartPreview", {investmentName = investmentName, previewModel = prop:GetEntityIndex(), sizeX = investment.BuildingSizeX, sizeY = investment.BuildingSizeY})
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
    local sizeX, sizeY
    -- RotatePreview
    if (data.rotation / 90) % 2 == 1 then
      sizeX, sizeY = investment.BuildingSizeY, investment.BuildingSizeX
    else
      sizeX, sizeY = investment.BuildingSizeX, investment.BuildingSizeY
    end
    local randomAngles = investment.BuildingRandomAngles
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
      local time = 4
      local animDistance = 400
      local fps = 30
      local step = animDistance / (time * fps)
      local startOrigin = Vector(origin.x, origin.y, origin.z - animDistance)
      CreateUnitByNameAsync(investment.UnitName, startOrigin, false, self:GetSelectedHeroEntity(plyID), self:GetSelectedHeroEntity(plyID), self:GetTeam(plyID), function(building)
        if randomAngles then
          building:SetAngles(0, RandomInt(0, 360), 0)
        else
          building:SetAngles(0, data.rotation, 0)
        end

        local constructionParticle = ParticleManager:CreateParticle("particles/misc/building_animation_debris.vpcf", PATTACH_ABSORIGIN_FOLLOW, building)
        ParticleManager:SetParticleControl(constructionParticle, 0, building:GetOrigin())
        building:SetHealth(1)
        building:SetOrigin(startOrigin)
        building:SetContextThink("contructionThink", function()
          if math.abs(origin.z - building:GetOrigin().z) <= step then
            building:SetOrigin(origin)
            ParticleManager:DestroyParticle(constructionParticle, false)
            ParticleManager:ReleaseParticleIndex(constructionParticle)
            return
          end
          if building:GetOrigin() ~= origin then
            building:Heal(building:GetMaxHealth() / (time * fps), building)
            startOrigin.z = startOrigin.z + step
            building:SetOrigin(startOrigin)
            return 1/fps
          end
        end, 0)
      end)
    end
  end
  DeepPrintTable(data)
end
CustomGameEventManager:RegisterListener("buildingRequestConstruction", function(...) PlayerResource:ProcessConstructionRequest(...) end)


function CDOTA_PlayerResource:OnBuildingCheckArea(eventSourceIndex, data)
  local origin = Vector(data.origin["0"], data.origin["1"], data.origin["2"])
  local sizeX, sizeY = data.sizeX, data.sizeY
  local areaBlocked = GridNav:IsAreaBlocked(origin, sizeX, sizeY)
  local previewModel = self:GetPreviewModel(data.PlayerID)
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
