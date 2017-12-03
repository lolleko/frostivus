GameMode.BuildingRange = 1280

function GameMode:GetSpiritTreeSpawnTable()
  -- local range = GameMode.BuildingRange
  -- local baseSpacing = 128
  -- local rangeSpaced = range + baseSpacing
  -- local groundHeight = GetGroundHeight(Vector(0, 0, 10000), nil)
  -- local spiritTreeSpawns = {
  --   {Vector(0, 0, groundHeight)}, -- Vertex
  --   {Vector(0, rangeSpaced, groundHeight), Vector(0, -rangeSpaced, groundHeight)}, -- Line
  --   {Vector(-rangeSpaced, -rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(0, rangeSpaced, groundHeight)}, -- Triangle
  --   {Vector(-rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, rangeSpaced, groundHeight), Vector(rangeSpaced, -rangeSpaced, groundHeight), Vector(-rangeSpaced, -rangeSpaced, groundHeight)}, -- Square
  -- }
  -- return spiritTreeSpawns
  return Entities:FindAllByName("spirit_tree_spawn")
end

function GameMode:OnPlayerPickHero(data)
  local hero = EntIndexToHScript(data.heroindex)
  local plyID = hero:GetPlayerOwnerID()

  -- delay player init to give player additoinal time to load
  GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("playerINIT" .. plyID), function()
    if self:IsPVP() then
      local cgData = PlayerResource:GetCGData(plyID)
      if cgData.competitiveGamesPlayed < 1 then
        PlayerResource:SetGameStage(plyID, 0)
      elseif cgData.competitiveGamesPlayed < 5 then
        PlayerResource:SetGameStage(plyID, 1)
      else
        PlayerResource:SetGameStage(plyID, 2)
      end
      local playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
      local spawn = self:GetSpiritTreeSpawnTable()[data.player]
      hero:SetRespawnPosition(spawn:GetOrigin())
      PlayerResource:SpawnBuilding(plyID, "npc_frostivus_spirit_tree_pvp", {origin = spawn:GetOrigin(), sizeX = 2, sizeY = 2, owner = hero}, function (args)
        PlayerResource:LoadPlayer(plyID, hero)
      end)
    else
      self:SetCoopSpiritTree(Entities:FindByName(nil, "coop_spirit_tree"))
      local plyID = plyID
      PlayerResource:SetLumberCapacity(plyID, PlayerResource:GetLumberCapacity(plyID) + self:GetSpiritTree(plyID).LumberCapacity)
      PlayerResource:SetGoldCapacity(plyID, PlayerResource:GetGoldCapacity(plyID) + self:GetSpiritTree(plyID).GoldCapacity)
    end
  end, 1)

  if PlayerResource:HasRandomed(plyID) then
    hero:ModifyGold(-200, false, 0)
  end
end

function GameMode:OnHeroSelection(data)
  -- try to set the tree here (coop)
  self:SetCoopSpiritTree(Entities:FindByName(nil, "coop_spirit_tree"))
end

function GameMode:OnStrategyTime()
  for _,plyID in pairs(PlayerResource:GetAll()) do
    if not PlayerResource:HasSelectedHero(plyID) then
      PlayerResource:SetHasRandomed(plyID)
      PlayerResource:GetPlayer(plyID):MakeRandomHeroSelection()
    end
  end
end

function GameMode:OnGameStart()
  -- init events
  -- events are coop only for now
  if not self:IsPVP() then
    self:InitQuests()
  end
  -- resend quest
  if not self:IsPVP() then
    self:AddQuest(QuestList.frostivus_quest_starter_kill_enemies, true)
  end

  -- test boss hp bar
  --CreateUnitByName("npc_frostivus_boss_roshan", Entities:FindByName(nil, "boss_test"):GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
end

function GameMode:OnThink()
  if not self.nextItemCleanUp or self.nextItemCleanUp < GameRules:GetGameTime() then
    for _, itemContainer in pairs(Entities:FindAllByClassname("dota_item_drop")) do
      local item = itemContainer:GetContainedItem()
      if item ~= nil then
      	if item:IsCastOnPickup() and (item:GetAbilityName() == "item_mana_potion" or item:GetAbilityName() == "item_health_potion") then
          if GameRules:GetGameTime() - itemContainer:GetCreationTime() >= 20 then
            itemContainer:RemoveSelf()
          end
        end
      end
    end
    self.nextItemCleanUp = GameRules:GetGameTime() + 10 
  end

end

function GameMode:OnPlayerThink(plyID)
  -- auto save every 5min
  if GM:IsPVPHome() and PlayerResource:GetLastSaveTime(plyID) + 60 <= GameRules:GetGameTime() and GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    PlayerResource:SetLastSaveTime(plyID, GameRules:GetGameTime())
    PlayerResource:StorePlayer(plyID)
  end
end

function GameMode:OnNPCSpawned(data)
  local spawnedUnit = EntIndexToHScript( data.entindex )
  if spawnedUnit ~= nil then
    if spawnedUnit:IsAncient() then
      CustomGameEventManager:Send_ServerToAllClients("frostivusBossStart", {bossEntIndex = data.entindex})
    end
  end
end

function GameMode:OnEntityKilled(data)
  local killedUnit = EntIndexToHScript(data.entindex_killed)
  if killedUnit ~= nil then
    if killedUnit:IsCreature() then
      if killedUnit:IsSpiritTree() then
        if self:IsPVP() then
          -- TODO check if other trees are still alive (in 2v2)
          local looser = killedUnit:GetTeamNumber()
          GameRules:MakeTeamLose(looser)
          if not self:IsPVPHome() then
            for _, plyID in pairs(PlayerResource:GetAllInTeam(looser)) do
              local cgData = PlayerResource:GetCGData(plyID)
              cgData.competitiveGamesPlayed = cgData.competitiveGamesPlayed + 1
              PlayerResource:UpdatePersitenData(plyID)
            end
            local winner = killedUnit:GetOpposingTeamNumber()
            for _, plyID in pairs(PlayerResource:GetAllInTeam(winner)) do
              local cgData = PlayerResource:GetCGData(plyID)
              cgData.competitiveGamesPlayed = cgData.competitiveGamesPlayed + 1
              cgData.competitiveGamesWon = cgData.competitiveGamesWon + 1
              PlayerResource:UpdatePersitenData(plyID)
            end
          else

          end
        else
          GameRules:MakeTeamLose(killedUnit:GetTeamNumber())
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
    if killedUnit:IsAncient() then
      CustomGameEventManager:Send_ServerToAllClients("frostivusBossEnd", {})
    end
  end
end

-- Make sure we dont go over the limit through kill bounties
function GameMode:GoldFilter(data)
  local plyIDKiller = data.player_id_const
  -- share gold bounties
  for _, plyID in pairs(PlayerResource:GetAllInTeam(PlayerResource:GetTeam(plyIDKiller))) do
    PlayerResource:ModifyGold(plyID, data.gold)
  end
  data.gold = 0
	return false
end

function GameMode:ItemAddedToInventoryFilter(data)
  local item = EntIndexToHScript(data.item_entindex_const)
  if item:GetAbilityName() == "item_tpscroll" and item:GetPurchaser() == nil then
    return false
  end
  return true
end
