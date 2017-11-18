GameMode.BuildingRange = 1280

function GameMode:GetSpiritTreeSpawnTable()
  local range = GameMode.BuildingRange
  local baseSpacing = 128
  local rangeSpaced = range + baseSpacing
  local groundHeight = GetGroundHeight(Vector(0, 0, 10000), nil)
  local spiritTreeSpawns = {
    {Vector(0, 0, groundHeight)}, -- Vertex
    {Vector(0, rangeSpaced, groundHeight), Vector(0, -rangeSpaced, groundHeight)}, -- Line
    {Vector(-rangeSpaced, -rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(0, rangeSpaced, groundHeight)}, -- Triangle
    {Vector(-rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(-rangeSpaced, -rangeSpaced, groundHeight)}, -- Square
  }
  return spiritTreeSpawns
end

function GameMode:OnPlayerPickHero(data)
  local hero = EntIndexToHScript(data.heroindex)

  if self:IsPVP() then
    local playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    local spawn = self:GetSpiritTreeSpawnTable()[playerCount][data.player]
    PlayerResource:SpawnBuilding(hero:GetPlayerOwnerID(), "npc_frostivus_spirit_tree_pvp", {origin = spawn, sizeX = 2, sizeY = 2, owner = hero})
  else
    self:SetCoopSpiritTree(Entities:FindByName(nil, "coop_spirit_tree"))
    local plyID = hero:GetPlayerOwnerID()
    PlayerResource:SetLumberCapacity(plyID, PlayerResource:GetLumberCapacity(plyID) + self:GetSpiritTree(plyID).LumberCapacity)
    PlayerResource:SetGoldCapacity(plyID, PlayerResource:GetGoldCapacity(plyID) + self:GetSpiritTree(plyID).GoldCapacity)
  end

  if PlayerResource:HasRandomed(hero:GetPlayerOwnerID()) then
    hero:ModifyGold(-200, false, 0)
  end
  --PlayerResource:AddQuest(hero:GetPlayerOwnerID(), QuestList.StartKillEnemies())
end

function GameMode:OnHeroSelection(data)
  -- try to set the tree here (coop)
  self:SetCoopSpiritTree(Entities:FindByName(nil, "coop_spirit_tree"))
end

function GameMode:OnPreGame()
  for _,plyID in pairs(PlayerResource:GetAll()) do
    if not PlayerResource:HasSelectedHero(plyID) then
      PlayerResource:SetHasRandomed(plyID)
      PlayerResource:GetPlayer(plyID):MakeRandomHeroSelection()
    end
  end
end

function GameMode:OnGameStart()
  -- init events
  self:InitQuests()
  -- resend quest
  self:AddQuest(QuestList.StartKillEnemies)
end

function GameMode:OnEntityKilled(data)
  local killedUnit = EntIndexToHScript(data.entindex_killed)
  if killedUnit ~= nil and killedUnit:IsCreature() and (killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
    if killedUnit:IsSpiritTree() then
      if self:IsPVP() then
        -- TODO
      else
        GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
      end
    end
    local ownerID = killedUnit:GetPlayerOwnerID()
    if ownerID ~= -1 then
      if killedUnit.LumberCapacity then
        local cap = PlayerResource:GetLumberCapacity(ownerID)
        PlayerResource:SetLumberCapacity(ownerID, cap - killedUnit.LumberCapacity)
        if PlayerResource:GetLumber(ownerID) > cap then
          PlayerResource:SetLumber(cap)
        end
      end
      if killedUnit.GoldCapacity then
        local cap = PlayerResource:GetGoldCapacity(ownerID)
        PlayerResource:SetGoldCapacity(ownerID, cap - killedUnit.GoldCapacity)
        if PlayerResource:GetGold(ownerID) > cap then
          PlayerResource:SetGold(ownerID, cap, true)
        end
      end
    end
  end
end

-- Make sure we dont go over the limit through kill bounties
function GameMode:GoldFilter(data)
  local plyIDKiller = data.player_id_const
  local hero = PlayerResource:GetSelectedHeroEntity(plyIDKiller)
  if hero:GetGold() + data.gold > PlayerResource:GetGoldCapacity(plyIDKiller) then
    data.gold = PlayerResource:GetGoldCapacity(plyIDKiller) - hero:GetGold()
  end
  -- share gold bounties
  for _, plyID in pairs(PlayerResource:GetAllInTeam(PlayerResource:GetTeam(plyIDKiller))) do
    if plyID ~= plyIDKiller then
      PlayerResource:ModifyGold(plyID, data.gold)
    end
  end
	return true
end
