-- TODO calculate these with dynamic build range
GameMode.BuildingRange = 1280
local range = GameMode.BuildingRange
local baseSpacing = 128
local rangeSpaced = range + baseSpacing
local groundHeight = 512
local spiritTreeSpawns = {
  {Vector(0, 0, groundHeight)},
  {Vector(0, rangeSpaced, groundHeight), Vector(0, -rangeSpaced, groundHeight)},
  {Vector(-rangeSpaced, -rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(0, rangeSpaced, groundHeight)},
  {Vector(-rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(-rangeSpaced, -rangeSpaced, groundHeight)},
}

function GameMode:OnPlayerPickHero(data)
  local playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_CUSTOM_1)
  local spawn = spiritTreeSpawns[playerCount][data.player]
  local hero = EntIndexToHScript(data.heroindex)
  PlayerResource:SpawnBuilding(hero:GetPlayerOwnerID(), "npc_frostivus_spirit_tree", {origin = spawn, sizeX = 2, sizeY = 2, owner = hero})
end

function GameMode:OnHeroSelection(data)
  for _,plyID in pairs(PlayerResource:GetAll()) do
    PlayerResource:GetPlayer(plyID):MakeRandomHeroSelection()
  end
end
