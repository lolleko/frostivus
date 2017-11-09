local QuestBase = class({})

function QuestBase:ModifyValue(valueName, change)
  self:SetValue(valueName, self:GetValue(valueName) + change)
end

function QuestBase:GetValue(valueName)
  return self.values[valueName]
end

function QuestBase:SetValue(valueName, value)
  self.values[valueName] = value
  local updateData = {questName = self.name, valueName = valueName, value = value}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_update", updateData)

  if self:IsCompleted() then
    self:Complete()
  end
end

function QuestBase:Complete()
  local completeData = {questName = self.name}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_completed", completeData)
  if self.rewards then
    if self.rewards.resource then
      for resourceName, amount in pairs(self.rewards.resource) do
        if resourceName == "xp" then
          PlayerResource:GetSelectedHeroEntity(self.plyID):AddExperience(amount, 0, false, false)
        elseif resourceName == "gold" then
          PlayerResource:ModifyGold(self.plyID, amount)
        elseif resourceName == "lumber" then
          PlayerResource:ModifyLumber(self.plyID, amount)
        end
      end
    end
  end
  self:OnCompleted()
  self:Destroy()
end

function QuestBase:Destroy()
  local destroyData = {questName = self.name}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_destroyed", destroyData)
  PlayerResource:RemoveQuest(self.plyID, self.name)
  self:OnDestroy()
end

function QuestBase:Fail()
  local completeData = {questName = self.name}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_failed", completeData)
  self:OnFailed()
  self:Destroy()
end

function QuestBase:IsCompleted()
  local completed = true
  for valueName, value in pairs(self.values) do
    if value < self.valueGoals[valueName] then
      completed = false
    end
  end
  return completed
end

function QuestBase:OnStart()

end

function QuestBase:OnFailed()

end

function QuestBase:OnCompleted()

end

function QuestBase:OnDestroy()

end


local questList = {}

SurviveGame = class(
  {
    name = "frostivus_quest_survive_game",
    description = "frostivus_quest_survive_game_description",
    values = {
      frostivus_quest_goal_spirit_tree_protect = 0,
      frostivus_quest_goal_kill_final_boss = 0
    },
    valueGoals = {
      frostivus_quest_goal_spirit_tree_protect = 1,
      frostivus_quest_goal_kill_final_boss = 1
    },
  },
  nil,
  QuestBase
)

StartKillEnemies = class(
  {
    name = "frostivus_quest_starter_kill_enemies",
    description = "frostivus_quest_starter_kill_enemies_description",
    values = {
      frostivus_quest_goal_killed_enemies = 0
    },
    valueGoals = {
      frostivus_quest_goal_killed_enemies = 10
    },
    rewards = {
      resource = {
        gold = 100,
        xp = 25
      }
    },
  },
  nil,
  QuestBase
)

function StartKillEnemies:OnStart()
  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and (killedUnit:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS) then
      print(self.plyID)
			self:ModifyValue("frostivus_quest_goal_killed_enemies", 1)
		end
  end, nil)
end

function StartKillEnemies:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
  PlayerResource:AddQuest(self.plyID, StartLumberCamp())
end

StartLumberCamp = class(
  {
    name = "frostivus_quest_starter_lumber_camp",
    description = "frostivus_quest_starter_lumber_camp_description",
    values = {
      frostivus_quest_goal_lumber_camp_constructed = 0
    },
    valueGoals = {
      frostivus_quest_goal_lumber_camp_constructed = 1
    },
    rewards = {
      resource = {
        gold = 50,
        lumber = 50,
        xp = 25,
      }
    },
  },
  nil,
  QuestBase
)

function StartLumberCamp:OnStart()
  self.npcSpawnedEventHandle = ListenToGameEvent("npc_spawned", function(event)
    local spawnedUnit = EntIndexToHScript( event.entindex )
  	if spawnedUnit ~= nil then
  		if spawnedUnit:GetPlayerOwnerID() == self.plyID and spawnedUnit:GetUnitName() == "npc_frostivus_lumber_camp_tier1" then
        self:ModifyValue("frostivus_quest_goal_lumber_camp_constructed", 1)
  		end
  	end
  end, nil)
end

function StartLumberCamp:OnDestroy()
  StopListeningToGameEvent(self.npcSpawnedEventHandle)
  PlayerResource:AddQuest(self.plyID, StartBuildSentry())
end

StartBuildSentry = class(
  {
    name = "frostivus_quest_starter_build_sentry",
    description = "frostivus_quest_starter_build_sentry_description",
    values = {
      frostivus_quest_goal_sentry_constructed = 0
    },
    valueGoals = {
      frostivus_quest_goal_sentry_constructed = 1
    },
    rewards = {
      resource = {
        xp = 25,
        lumber = 180,
      }
    },
  },
  nil,
  QuestBase
)

function StartBuildSentry:OnStart()
  self.npcSpawnedEventHandle = ListenToGameEvent("npc_spawned", function(event)
    local spawnedUnit = EntIndexToHScript( event.entindex )
  	if spawnedUnit ~= nil then
  		if spawnedUnit:GetPlayerOwnerID() == self.plyID and spawnedUnit:GetUnitName() == "npc_frostivus_defense_lookout_tier1" then
        self:ModifyValue("frostivus_quest_goal_sentry_constructed", 1)
  		end
  	end
  end, nil)
end

function StartBuildSentry:OnDestroy()
  StopListeningToGameEvent(self.npcSpawnedEventHandle)
  PlayerResource:AddQuest(self.plyID, StartBuildWalls())
end

StartBuildWalls = class(
  {
    name = "frostivus_quest_starter_build_walls",
    description = "frostivus_quest_starter_build_walls_description",
    values = {
      frostivus_quest_goal_walls_constructed = 0
    },
    valueGoals = {
      frostivus_quest_goal_walls_constructed = 6
    },
    rewards = {
      resource = {
        xp = 50
      }
    },
  },
  nil,
  QuestBase
)

function StartBuildWalls:OnStart()
  self.npcSpawnedEventHandle = ListenToGameEvent("npc_spawned", function(event)
    local spawnedUnit = EntIndexToHScript( event.entindex )
  	if spawnedUnit ~= nil then
  		if spawnedUnit:GetPlayerOwnerID() == self.plyID and  spawnedUnit:GetUnitName() == "npc_frostivus_defense_wall_tier1" then
        self:ModifyValue("frostivus_quest_goal_walls_constructed", 1)
  		end

  	end
  end, nil)
end

function StartBuildWalls:OnDestroy()
  StopListeningToGameEvent(self.npcSpawnedEventHandle)
end
