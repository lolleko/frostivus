--possible sizes for buildings
-- 2x2, 4x4, 8x8 ...
-- 2x4, 2x8, 4x8 ...
-- pos is the "enter" of the building
function GridNav:IsAreaBlocked(pos, sizeX, sizeY)
  -- x is right/left
  -- y is top/down
  -- z is up/down

  if sizeX == 0 or sizeY == 0 then return false end

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
      -- local ents = Entities:FindAllInSphere(gridPointer, 64)
      -- for _, v in pairs(ents) do
      --   if v:IsAlive() and (v:IsNPC() and (v:IsHero() or v:IsCreep() or v:IsCreature())) then
      --     return true
      --   end
      -- end
      gridPointer.y = gridPointer.y - 32
    end
    gridPointer.x = gridPointer.x + 32
  end
  return false
end

function GridNav:GetBlockedInSquare(center, range, compress)
  local groundHeight = GetGroundHeight(center, nil)
  local blockedSquares = {}
  local blockedSquaresZipped = {}
  blockedSquaresZipped.topLeft = Vector(center.x - range + 32, center.y + range - 32, groundHeight)
  local lines = {}
  for y=range,-range,-64  do
    local line = {}
    for x=-range,range,64  do
      local squarePos = Vector(center.x + x + 32, center.y + y - 32, groundHeight)
      if GridNav:IsBlocked(squarePos) then
        if compress then
          line[#line + 1] = 1
        else
          blockedSquares[#blockedSquares + 1] = squarePos
        end
      else
        if compress then
          line[#line + 1] = 0
        end
      end
    end
    if compress then
      lines[#lines + 1] = table.concat(line)
    end
  end
  -- we could even zip this more by encoding the lines in decimal but his will be enough for now (because deadline and simplicity)
  -- this will keep the size of blockedSquaresZipped below 8KB when networked
  -- and even more if i knew how custom messages are networked... JSON string?
  -- right now this consumes 3-8KB i could easily reduce it to 375 bytes - 1KB
  if compress then
    blockedSquaresZipped.lines = table.concat(lines, ";")
    for _,v in pairs(lines) do
      print(v)
    end
    print("---END---")
    return blockedSquaresZipped
  end
  return blockedSquares
end

function GridNav:IsPositionInSquare(center, radius, position, sizeX, sizeY)
  return math.abs(center.x - position.x) + sizeX * 32 <= radius and math.abs(center.y - position.y) + sizeY * 32 <= radius
end
