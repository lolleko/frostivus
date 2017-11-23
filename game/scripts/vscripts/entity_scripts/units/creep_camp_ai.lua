function Spawn()
  Interval = 4

  thisEntity.CampLocation = thisEntity:GetOrigin()
  thisEntity:SetContextThink("SetOriging", function() thisEntity.CampLocation = thisEntity:GetOrigin() end, 0)
  thisEntity:SetContextThink("OrderThink", OrderThink, 1)
end

function OrderThink()
  if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return 10 end

  if (thisEntity:GetOrigin() - thisEntity.CampLocation:GetOrigin()):Length2D() >= 1200 then
    ExecuteOrderFromTable({
      UnitIndex = thisEntity:entindex(),
      OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
      Position = thisEntity.CampLocation:GetOrigin(),
    })
  end

  return Interval
end
