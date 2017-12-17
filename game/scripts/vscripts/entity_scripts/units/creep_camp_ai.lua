function Spawn()
  Interval = 3

  thisEntity.CampLocation = thisEntity:GetOrigin()
  thisEntity:SetContextThink("SetOriginDelayed", function() thisEntity.CampLocation = thisEntity:GetOrigin() end, 0)
  thisEntity:SetContextThink("OrderThink", OrderThink, 1)
end

function OrderThink()
  if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return 10 end

  if (thisEntity:GetOrigin() - thisEntity.CampLocation):Length2D() >= 1200 then
    ExecuteOrderFromTable({
      UnitIndex = thisEntity:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = thisEntity.CampLocation,
    })
  end

  return Interval
end
