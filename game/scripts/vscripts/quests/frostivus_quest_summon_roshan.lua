local frostivus_quest_summon_roshan = class(
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
    nextQuest = {
      questClass = "frostivus_quest_kill_roshan",
      nlyOnCompleted = true,
      allPlayers = true
    }
  },
  nil,
  QuestBase
)

function frostivus_quest_summon_roshan:OnStart()
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
        AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnPoint:GetOrigin() + Vector(0, 0, 30), 400, 60, false)
        GM:SendMinimapPing(spawnPoint:GetOrigin())
        revealDragon = false
      end
    elseif lizardCount ~= 0 then
      CreateUnitByNameAsync("npc_frostivus_cheese_lizard", spawnPoint:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function()
      end)
      lizardCount = lizardCount - 1
      if revealLizard then
        -- reveal one unit
        AddFOWViewer(DOTA_TEAM_GOODGUYS, spawnPoint:GetOrigin() + Vector(0, 0, 30), 400, 60, false)
        GM:SendMinimapPing(spawnPoint:GetOrigin())
        revealLizard = false
      end
    end
  end
  -- Ping pit and reveal fog
  local pitOrigin = Entities:FindByName(nil, "roshan_bones_skull"):GetOrigin()
  GM:SendMinimapPing(pitOrigin)
  AddFOWViewer(DOTA_TEAM_GOODGUYS, pitOrigin + Vector(0, 0, 80), 800, 120, false)
end

return frostivus_quest_summon_roshan
