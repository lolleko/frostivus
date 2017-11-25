local frostivus_quest_starter_build_sentry = class(
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
    events = {
      "npc_spawned"
    },
    nextQuest = {
      questClass = "frostivus_quest_starter_build_walls",
      onlyOnCompleted = false
    }
  },
  nil,
  QuestBase
)

function frostivus_quest_starter_build_sentry:OnNPCSpawned(event)
  local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit ~= nil then
		if spawnedUnit:GetPlayerOwnerID() == self.plyID and spawnedUnit:GetUnitName() == "npc_frostivus_defense_lookout_tier1" then
      self:ModifyValue("frostivus_quest_goal_sentry_constructed", 1)
		end
	end
end

return frostivus_quest_starter_build_sentry
