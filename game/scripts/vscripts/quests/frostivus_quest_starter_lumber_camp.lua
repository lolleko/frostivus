local frostivus_quest_starter_lumber_camp = class(
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
    events = {
      "npc_spawned"
    },
    nextQuest = {
      questClass = "frostivus_quest_starter_build_sentry",
      onlyOnCompleted = false
    }
  },
  nil,
  QuestBase
)

function frostivus_quest_starter_lumber_camp:OnNPCSpawned(event)
  local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit ~= nil then
		if spawnedUnit:GetPlayerOwnerID() == self.plyID and spawnedUnit:GetUnitName() == "npc_frostivus_lumber_camp_tier1" then
      self:ModifyValue("frostivus_quest_goal_lumber_camp_constructed", 1)
		end
	end
end

return frostivus_quest_starter_lumber_camp
