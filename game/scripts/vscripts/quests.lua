-- Do not polute gobal NS with evvery single quest -> group them
QuestList = {}

local StartKillEnemies = class(
  {
    name = "frostivus_quest_starter_kill_enemies",
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
QuestList.StartKillEnemies = StartKillEnemies

function StartKillEnemies:OnStart()
  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and (killedUnit:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS) then
			self:ModifyValue("frostivus_quest_goal_killed_enemies", 1)
		end
  end, nil)
end

function StartKillEnemies:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
  PlayerResource:AddQuest(self.plyID, QuestList.StartLumberCamp())
end

local StartLumberCamp = class(
  {
    name = "frostivus_quest_starter_lumber_camp",
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
QuestList.StartLumberCamp = StartLumberCamp

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
  PlayerResource:AddQuest(self.plyID, QuestList.StartBuildSentry())
end

local StartBuildSentry = class(
  {
    name = "frostivus_quest_starter_build_sentry",
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
QuestList.StartBuildSentry = StartBuildSentry

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
  PlayerResource:AddQuest(self.plyID, QuestList.StartBuildWalls())
end

local StartBuildWalls = class(
  {
    name = "frostivus_quest_starter_build_walls",
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
QuestList.StartBuildWalls = StartBuildWalls

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
  PlayerResource:AddQuest(self.plyID, QuestList.StartGoldCamp())
end

local StartGoldCamp = class(
  {
    name = "frostivus_quest_starter_gold_camp",
    values = {
      frostivus_quest_goal_gold_camp_constructed = 0
    },
    valueGoals = {
      frostivus_quest_goal_gold_camp_constructed = 1
    },
    rewards = {
      resource = {
        gold = 50,
        xp = 100,
      }
    },
  },
  nil,
  QuestBase
)
QuestList.StartGoldCamp = StartGoldCamp

function StartGoldCamp:OnStart()
  self.npcSpawnedEventHandle = ListenToGameEvent("npc_spawned", function(event)
    local spawnedUnit = EntIndexToHScript( event.entindex )
  	if spawnedUnit ~= nil then
  		if spawnedUnit:GetPlayerOwnerID() == self.plyID and spawnedUnit:GetUnitName() == "npc_frostivus_gold_camp_tier1" then
        self:ModifyValue("frostivus_quest_goal_gold_camp_constructed", 1)
  		end
  	end
  end, nil)
end

function StartGoldCamp:OnDestroy()
  StopListeningToGameEvent(self.npcSpawnedEventHandle)
  GM:AddQuest(QuestList.SummonRoshan)
end

local SummonRoshan = class(
  {
    name = "frostivus_quest_summon_roshan",
    values = {
      frostivus_quest_goal_summon_roshan_chicken = 0,
      frostivus_quest_goal_summon_roshan_cheese = 0
    },
    valueGoals = {
      frostivus_quest_goal_summon_roshan_chicken = 5,
      frostivus_quest_goal_summon_roshan_cheese = 5
    },
    rewards = {
      resource = {
        gold = 200,
        lumber = 100,
        xp = 100,
      }
    },
    static = {
      dragonsSpawned = false
    },
  },
  nil,
  QuestBase
)
QuestList.SummonRoshan = SummonRoshan

function SummonRoshan:OnStart()
  -- dragonsSpawned is static therefore this only will run once
  if not self.static.dragonsSpawned then
    local spawnPoints = Entities:FindAllByName("cheese_dragon_spawn")
    -- not all spawns will be used os shuffle a bit
    table.shuffle(spawnPoints)
    local dragonCount = 5
    local lizardCount = 5
    local revealDragon = true
    local revealLizard = true
    for _, spawnPoint in pairs(spawnPoints) do
      -- TODO code duplciation
      if dragonCount ~= 0 then
        CreateUnitByNameAsync("npc_frostivus_cheese_dragon", spawnPoint:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function()
        end)
        dragonCount = dragonCount - 1
        if revealDragon then
          -- reveal one unit
          AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnPoint:GetOrigin() + Vector(0, 0, 30), 400, 30, false)
          PlayerResource:SendMinimapPing(self.plyID, spawnPoint:GetOrigin(), true)
          revealDragon = false
        end
      elseif lizardCount ~= 0 then
        CreateUnitByNameAsync("npc_frostivus_cheese_lizard", spawnPoint:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function()
        end)
        lizardCount = lizardCount - 1
        if revealLizard then
          -- reveal one unit
          AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnPoint:GetOrigin() + Vector(0, 0, 30), 400, 30, false)
          PlayerResource:SendMinimapPing(self.plyID, spawnPoint:GetOrigin(), true)
          revealLizard = false
        end
      end
    end
    -- Ping pit and reveal fog
    local pitOrigin = Entities:FindByName(nil, "roshan_bones_skull"):GetOrigin()
    PlayerResource:SendMinimapPing(self.plyID, pitOrigin, true)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, pitOrigin + Vector(0, 0, 80), 800, 20, false)
    self.static.dragonsSpawned = true
  end
end

function SummonRoshan:OnDestroy()
  GM:AddQuest(QuestList.KillRoshan)
end

local KillRoshan = class(
  {
    name = "frostivus_quest_kill_roshan",
    values = {
      frostivus_quest_goal_kill_roshan = 0
    },
    valueGoals = {
      frostivus_quest_goal_kill_roshan = 2
    },
    rewards = {
      resource = {
        gold = 500,
        lumber = 500,
        xp = 500,
      }
    },
  },
  nil,
  QuestBase
)
QuestList.KillRoshan = KillRoshan

function KillRoshan:OnStart()
  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and killedUnit:GetUnitName() == "npc_frostivus_boss_roshan" then
			self:ModifyValue("frostivus_quest_goal_kill_roshan", 1)
		end
  end, nil)
end

function KillRoshan:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
  GM:AddQuest(QuestList.DestroySnowMakers)
  GM:SetStage(1)
end

local DestroySnowMakers = class(
  {
    name = "frostivus_quest_destroy_snow_makers",
    values = {
      frostivus_quest_goal_destroy_snow_makers = 0
    },
    valueGoals = {
      frostivus_quest_goal_destroy_snow_makers = 2
    },
    rewards = {
      resource = {
        gold = 1200,
        lumber = 1200,
        xp = 1000,
      }
    },
  },
  nil,
  QuestBase
)
QuestList.DestroySnowMakers = DestroySnowMakers

function DestroySnowMakers:OnStart()
  local snowMakers = Entities:FindAllByName("npc_frostivus_snow_maker")
  self.valueGoals.frostivus_quest_goal_destroy_snow_makers = #snowMakers
  for _, ent in pairs(snowMakers) do
    ent:RemoveModifierByName("modifier_invulnerable")
    PlayerResource:SendMinimapPing(self.plyID, ent:GetOrigin(), true)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, ent:GetOrigin() + Vector(0, 0, 30), 250, 12, false)
  end

  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and killedUnit:GetUnitName() == "npc_frostivus_snow_maker" then
			self:ModifyValue("frostivus_quest_goal_destroy_snow_makers", 1)
		end
  end, nil)
end

function DestroySnowMakers:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
  GM:AddQuest(QuestList.KillStoregga)
end

local KillStoregga = class(
  {
    name = "frostivus_quest_goal_kill_storegga",
    values = {
      frostivus_quest_goal_kill_storegga = 0
    },
    valueGoals = {
      frostivus_quest_goal_kill_storegga = 1
    },
    rewards = {
      resource = {
        gold = 2000,
        lumber = 2000,
        xp = 2500,
      }
    },
    statics = {
      storegga_spawned = false
    }
  },
  nil,
  QuestBase
)
QuestList.KillStoregga = KillStoregga

function KillStoregga:OnStart()
  if not self.static.storrega_spawned then
    local spawn = Entities:FindByName(nil, "storegga_spawn"):GetOrigin()
    CreateUnitByNameAsync("npc_frostivus_boss_storegga", spawn, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)

    end)
    PlayerResource:SendMinimapPing(self.plyID, spawn, true)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawn + Vector(0, 0, 30), 800, 5, false)
  end
  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and killedUnit:GetUnitName() == "npc_frostivus_boss_storegga" then
			self:ModifyValue("frostivus_quest_goal_kill_storegga", 1)
		end
  end, nil)
end

function KillStoregga:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
end
