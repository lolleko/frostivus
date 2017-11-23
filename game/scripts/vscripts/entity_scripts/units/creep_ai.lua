function Spawn()
  -- onyl perform this every few seconds since we calculate path lengths
  Interval = 5
  thisEntity:SetContextThink("OrderThink", OrderThink, 1)
end

function OrderThink()
  if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return 10 end

  if (thisEntity:GetOrigin() - GM:GetSpiritTree():GetOrigin()):Length2D() >= GM:GetBuildingRange() then
    ExecuteOrderFromTable({
      UnitIndex = thisEntity:entindex(),
      OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
      Position = GM:GetSpiritTree():GetOrigin(),
    })
    return Interval / 2
  end

  local overwriteTarget
  local range
  if thisEntity:IsRangedAttacker() then
    local buildings = Entities:FindBuildingInRadius(thisEntity:GetOrigin(), DOTA_TEAM_GOODGUYS, thisEntity:GetAttackRange(), FROSTIVUS_BUILDING_LOOKOUT)
    if #buildings > 0 then
      overwriteTarget = buildings[0]
    end
  else
    -- this part is really resource intensive
    local buildings = Entities:FindBuildingInRadius(thisEntity:GetOrigin(), DOTA_TEAM_GOODGUYS, thisEntity:GetCurrentVisionRange(), FROSTIVUS_BUILDING_LOOKOUT)
    local minDist = -1
    local closest
    for k, bld in pairs(buildings) do
      local freeSquare = GetFreeSquareAroundBuilding(bld:GetOrigin(), bld:GetUnitName())
      if freeSquare then
        local pathLength = GridNav:FindPathLength(thisEntity:GetOrigin(), freeSquare)
        if pathLength ~= -1 and (minDist == -1 or pathLength < minDist) and pathLength <= thisEntity:GetCurrentVisionRange() then
          closest = bld
          minDist = pathLength
        end
      end
    end
    overwriteTarget = closest
  end
  if overwriteTarget then
    ExecuteOrderFromTable({
      UnitIndex = thisEntity:entindex(),
      OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
      TargetIndex = overwriteTarget:entindex()
    })
    ExecuteOrderFromTable({
      UnitIndex = thisEntity:entindex(),
      OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
      Position = GM:GetSpiritTree():GetOrigin(),
      Queue = true
    })
    -- wait a bit more if we executed a direct attack order
    return Interval * 2
  end
  return Interval
end

function GetFreeSquareAroundBuilding(pos, name)
  local sizeX, sizeY = BuildingKV:GetSize(name)
  sizeX = sizeX + 1
  sizeY = sizeY + 1
  local gridPointer = Vector(pos.x - (sizeX / 2) * 64, pos.y + (sizeY / 2) * 64, pos.z)
  local initialY = gridPointer.y
  for x=1, sizeX  do
    gridPointer.y = initialY
    gridPointer.x = gridPointer.x + 32
    for y=1, sizeY do
      gridPointer.y = gridPointer.y - 32
      if GridNav:IsTraversable(gridPointer) and not GridNav:IsBlocked(gridPointer) then
        return gridPointer
      end
      gridPointer.y = gridPointer.y - 32
    end
    gridPointer.x = gridPointer.x + 32
  end
  return nil
end
