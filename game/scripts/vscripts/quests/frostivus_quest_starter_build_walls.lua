local frostivus_quest_starter_build_walls = class(
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
        xp = 100
      }
    },
    events = {
      "npc_spawned"
    },
    nextQuest = {
      questClass = "frostivus_quest_starter_gold_camp",
      onlyOnCompleted = false
    }
  },
  nil,
  QuestBase
)

function frostivus_quest_starter_build_walls:OnNPCSpawned(event)
  local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit ~= nil then
		if spawnedUnit:GetPlayerOwnerID() == self.plyID and  spawnedUnit:GetUnitName() == "npc_frostivus_defense_wall_tier1" then
      self:ModifyValue("frostivus_quest_goal_walls_constructed", 1)
		end
	end
end

return frostivus_quest_starter_build_walls
