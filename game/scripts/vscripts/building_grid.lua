--pssoible sizes for buildings
-- 2x2, 4x4, 8x8 ...
-- 2x4, 2x8, 4x8 ...
-- pos is the "enter" of the building
function GridNav:IsAreaBlocked(pos, sizeX, sizeY)
  -- x is right/left
  -- y is top/down
  -- z is up/down

  -- begin in the top right corner
  local gridPointer = Vector(pos.x - (sizeX / 2) * 64, pos.y + (sizeY / 2) * 64, pos.z)
  local initialY = gridPointer.y
  for x=1, sizeX  do
    gridPointer.y = initialY
    gridPointer.x = gridPointer.x + 32
    for y=1, sizeY do
      gridPointer.y = gridPointer.y - 32
      if not self:IsTraversable(gridPointer) or self:IsBlocked(gridPointer) then
        return true
      end
      local ents = Entities:FindAllInSphere(gridPointer, 64)
      for _, v in pairs(ents) do
        if v:IsAlive() and string.match(v:GetClassname(), "npc_") and v:GetClassname() ~= "npc_dota_companion" then
          return true
        end
      end
      gridPointer.y = gridPointer.y - 32
    end
    gridPointer.x = gridPointer.x + 32
  end
  return false
end
