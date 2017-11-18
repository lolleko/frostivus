QuestEventList = {}

local ZombieArmy = class(
  {
    name = "frostivus_event_zombie_army",
    values = {
      frostivus_quest_goal_destroy_tombstones = 0
    },
    valueGoals = {
      frostivus_quest_goal_destroy_tombstones = 8
    },
    rewards = {
      resource = {
        gold = 150,
        lumber = 100,
        xp = 100
      }
    },
    timeLimit = 150,
    statics = {
      tombstonesDropped = false
    }
  },
  nil,
  QuestBase
)
QuestEventList.ZombieArmy = ZombieArmy

function ZombieArmy:OnStart()
  local tombsToSpawn = 4
  self.valueGoals.frostivus_quest_goal_destroy_tombstones = tombsToSpawn
  self.timeLimit = tombsToSpawn * 40
  if not self.statics.tombstonesDropped then
    local spawnPoints = Entities:FindAllByName("zombie_army_toombstone_spawn")
    table.shuffle(spawnPoints)
    for _, spawnPoint in pairs(spawnPoints) do
      if tombsToSpawn ~= 0 then
        CreateUnitByNameAsync("npc_frostivus_zombie_army_tombstone", spawnPoint:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
          AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnPoint:GetOrigin() + Vector(0, 0, 30), 100, self.timeLimit, false)
          GM:ScaleUnit(unit)
          PlayerResource:SendMinimapPing(self.plyID, spawnPoint:GetOrigin(), true)
          unit:AddNewModifier(unit, nil, "modifier_kill", {duration = self.timeLimit})
        end)
        tombsToSpawn = tombsToSpawn - 1
      end
    end
    self.statics.tombstonesDropped = true
  end

  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and (killedUnit:GetUnitName() == "npc_frostivus_zombie_army_tombstone") then
			self:ModifyValue("frostivus_quest_goal_destroy_tombstones", 1)
		end
  end, nil)
end

function ZombieArmy:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
  self.statics.tombstonesDropped = false
end

local SkeletonArmy = class(
  {
    name = "frostivus_event_skeleton_army",
    values = {
      --frostivus_quest_goal_kill_boss_skeleton = 0,
      frostivus_quest_goal_kill_skeletons = 0
    },
    valueGoals = {
      --frostivus_quest_goal_kill_boss_skeleton = 1,
      frostivus_quest_goal_kill_skeletons = 0
    },
    rewards = {
      resource = {
        gold = 100,
        lumber = 100,
        xp = 80
      }
    },
    statics = {
      skeletonsSpawned = false
    }
  },
  nil,
  QuestBase
)
QuestEventList.SkeletonArmy = SkeletonArmy

function SkeletonArmy:OnStart()
  local skeletonsToSpawnPerLine = 4
  self.valueGoals.frostivus_quest_goal_kill_skeletons = skeletonsToSpawnPerLine * 4

  if not self.statics.skeletonsSpawned then
    local functionSpawnLine = function(corner1, corner2)
      corner1 = Entities:FindByName(nil, corner1):GetOrigin()
      corner2 = Entities:FindByName(nil, corner2):GetOrigin()
      local line = (corner1 - corner2)
      local padding = line / skeletonsToSpawnPerLine
      for i=1, skeletonsToSpawnPerLine do
        local randomOffset = RandomVector(200)
        randomOffset.z = 0
        local spawn = corner2 + padding * i + randomOffset
        CreateUnitByNameAsync("npc_frostivus_skeleton_army_skeleton", spawn, true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
          GM:ScaleUnit(unit)
          AddFOWViewer(DOTA_TEAM_GOODGUYS, spawn + Vector(0, 0, 30), 100, 2, false)
          PlayerResource:SendMinimapPing(self.plyID, spawn, true)
        end)
      end
    end
    -- clock wise
    functionSpawnLine("skeleton_army_corner_top_left", "skeleton_army_corner_top_right")
    functionSpawnLine("skeleton_army_corner_top_right", "skeleton_army_corner_bottom_right")
    functionSpawnLine("skeleton_army_corner_bottom_right", "skeleton_army_corner_bottom_left")
    functionSpawnLine("skeleton_army_corner_bottom_left", "skeleton_army_corner_top_left")

    self.statics.skeletonsSpawned = true
  end

  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and (killedUnit:GetUnitName() == "npc_frostivus_skeleton_army_skeleton") then
			self:ModifyValue("frostivus_quest_goal_kill_skeletons", 1)
		end
  end, nil)
end

function SkeletonArmy:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
  self.statics.skeletonsSpawned = false
end

local ItemDrop = class(
  {
    name = "frostivus_event_item_drop",
    values = {
      frostivus_quest_goal_intercept_carrier = 0
    },
    valueGoals = {
      frostivus_quest_goal_intercept_carrier = 1,
    },
    statics = {
      carrierSpawned = false
    }
  },
  nil,
  QuestBase
)
QuestEventList.ItemDrop = ItemDrop

function ItemDrop:OnStart()
  if not self.statics.carrierSpawned then
    local routes = {
      {spawn = "item_drop_carrier_spawn1", goal = "item_drop_carrier_spawn3"},
      {spawn = "item_drop_carrier_spawn3", goal = "item_drop_carrier_spawn4"},
      {spawn = "item_drop_carrier_spawn4", goal = "item_drop_carrier_spawn2"},
      {spawn = "item_drop_carrier_spawn2", goal = "item_drop_carrier_spawn1"},
    }
    local route = routes[math.random(#routes)]
    local spawn = Entities:FindByName(nil, route.spawn)
    local goal = Entities:FindByName(nil, route.goal)
    CreateUnitByNameAsync("npc_frostivus_item_drop_carrier", spawn:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
      GM:ScaleUnit(unit)
      unit:AddNewModifier(unit, nil, "modifier_provides_fow_position", {team = DOTA_TEAM_GOODGUYS})
      AddFOWViewer(DOTA_TEAM_GOODGUYS, spawn:GetOrigin() + Vector(0, 0, 30), 1000, 2, false)
      AddFOWViewer(DOTA_TEAM_GOODGUYS, goal:GetOrigin() + Vector(0, 0, 30), 1000, 2, false)
      PlayerResource:SendMinimapPing(self.plyID, spawn:GetOrigin(), true)
      unit:SetContextThink("disseaperWhenClose", function()
        unit:MoveToPosition(goal:GetOrigin())
        if (goal:GetOrigin() - unit:GetOrigin()):Length2D() <= 500 then
          unit.preventDrop = true
          unit:Kill(nil, unit)
        end
        return 5
      end, 2)
    end)
    self.statics.carrierSpawned = true
  end

  self.entityKillEventHandle = ListenToGameEvent("entity_killed", function(event)
    local killedUnit = EntIndexToHScript( event.entindex_killed )
		if killedUnit ~= nil and killedUnit:IsCreature() and (killedUnit:GetUnitName() == "npc_frostivus_item_drop_carrier" and not killedUnit.preventDrop) then
      local item = items[GM:GetStage() - 1][math.random(#items)]
      killedUnit:DropItemAtPosition(killedUnit:GetOrigin(), item)
  		self:ModifyValue("frostivus_quest_goal_intercept_carrier", 1)
		end
    local items = {
      {
        "item_blight_stone",
        "item_boots",
        "item_wind_lace",
        "item_ring_of_protection",
        "item_ring_of_regen",
        "item_sobi_mask",
        "item_blades_of_attack",
        "item_gloves",
        "item_robe",
        "item_belt_of_strength",
        "item_boots_of_elves",
        "item_chainmail",
        "item_void_stone",
        "item_ring_of_health",
        "item_helm_of_iron_will",
        "item_energy_booster",
        "item_vitality_booster",
        "item_lifesteal",
        "item_broadsword",
      },
      {
        "item_broadsword",
      },
      {
        "item_broadsword",
      }
    }
  end, nil)
end

function ItemDrop:OnDestroy()
  StopListeningToGameEvent(self.entityKillEventHandle)
  self.statics.carrierSpawned = false
end

GameMode.EventList = {
  {
    class = ZombieArmy,
    stages = {0, 1},
    cooldown = 1200,
    weight = 4,
  },
  {
    class = SkeletonArmy,
    stages = {0},
    cooldown = 900,
    weight = 7,
  },
  {
    class = ItemDrop,
    stages = {0, 1, 2},
    cooldown = 1200,
    small = true,
    weight = 4,
  },
  -- {
  --   class = GreevilsOnTheRun,
  --   stages = {0, 1, 2},
  --   cooldown = 1200,
  --   weight = 3,
  -- }
}
