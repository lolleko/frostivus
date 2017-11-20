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
  local currentNum = ""
  local count = 0
  for y=range,-range,-64  do
    local line = {}
    currentNum = ""
    blockedSquaresZipped.padding = count
    count = 0
    for x=-range,range,64  do
      if count == 4 then
        line[#line + 1] = string.format("%x", tonumber(currentNum, 2))
        currentNum = ""
        count = 0
      end
      local squarePos = Vector(center.x + x + 32, center.y + y - 32, groundHeight)
      if GridNav:IsBlocked(squarePos) then
        if compress then
          currentNum = currentNum .. 1
        else
          blockedSquares[#blockedSquares + 1] = squarePos
        end
      else
        if compress then
          currentNum = currentNum .. 0
        end
      end
      count = count + 1
    end
    if compress then
      lines[#lines + 1] = table.concat(line)
    end
  end
  -- I could even zip this more but this will be enough for now (because deadline and simplicity)
  -- I currently convert to hex and not unicode because unicode support is weird in js and lua 5.1
  -- anyway this will keep the size of blockedSquaresZipped below 2KB when networked (assuming a character consumes 1byte)
  -- this will result in ~2kb/s for each building preview
  -- but careful this will grow exponentialy with the building range
  if compress then
    blockedSquaresZipped.lines = table.concat(lines, ";")
    return blockedSquaresZipped
  end
  return blockedSquares
end

function GridNav:IsPositionInSquare(center, radius, position, sizeX, sizeY)
  return math.abs(center.x - position.x) + sizeX * 32 <= radius and math.abs(center.y - position.y) + sizeY * 32 <= radius
end
