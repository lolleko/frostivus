local frostivus_quest_destroy_snow_makers = class(
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
    events = {
      "entity_killed"
    },
    nextQuest = {
      questClass = "frostivus_quest_kill_storegga",
      allPlayers = true
    }
  },
  nil,
  QuestBase
)

function frostivus_quest_destroy_snow_makers:OnStart()
  local snowMakers = Entities:FindAllByName("npc_frostivus_snow_maker")
  self.valueGoals.frostivus_quest_goal_destroy_snow_makers = #snowMakers
  for _, ent in pairs(snowMakers) do
    ent:RemoveModifierByName("modifier_invulnerable")
    GM:SendMinimapPing(ent:GetOrigin())
    AddFOWViewer(DOTA_TEAM_GOODGUYS, ent:GetOrigin() + Vector(0, 0, 30), 250, 12, false)
  end
end

function frostivus_quest_destroy_snow_makers:OnEntityKilled(event)
  local killedUnit = EntIndexToHScript( event.entindex_killed )
	if killedUnit ~= nil and killedUnit:IsCreature() and killedUnit:GetUnitName() == "npc_frostivus_snow_maker" then
		self:ModifyValue("frostivus_quest_goal_destroy_snow_makers", 1)
	end
end

return frostivus_quest_destroy_snow_makers
