-- TODO calculate these with dynamic build range
GameMode.BuildingRange = 1280


function GameMode:GetSpiritTreeSpawnTable()
  local range = GameMode.BuildingRange
  local baseSpacing = 128
  local rangeSpaced = range + baseSpacing
  local groundHeight = GetGroundHeight(Vector(0, 0, 10000), nil)
  local spiritTreeSpawns = {
    {Vector(0, 0, groundHeight)},
    {Vector(0, rangeSpaced, groundHeight), Vector(0, -rangeSpaced, groundHeight)},
    {Vector(-rangeSpaced, -rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(0, rangeSpaced, groundHeight)},
    {Vector(-rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(-rangeSpaced, -rangeSpaced, groundHeight)},
  }
  return spiritTreeSpawns
end

function GameMode:OnPlayerPickHero(data)
  local playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
  local spawn = self:GetSpiritTreeSpawnTable()[playerCount][data.player]
  local hero = EntIndexToHScript(data.heroindex)
  PlayerResource:SpawnBuilding(hero:GetPlayerOwnerID(), "npc_frostivus_spirit_tree", {origin = spawn, sizeX = 2, sizeY = 2, owner = hero})
  AddFOWViewer(hero:GetTeam(), spawn, 16000, 0.1, false)
end

function GameMode:OnHeroSelection(data)
  for _,plyID in pairs(PlayerResource:GetAll()) do
    PlayerResource:GetPlayer(plyID):MakeRandomHeroSelection()
  end
end
