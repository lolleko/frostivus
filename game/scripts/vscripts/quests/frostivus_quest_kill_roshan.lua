local frostivus_quest_kill_roshan =
    class(
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
                xp = 500
            }
        },
        events = {
            "entity_killed"
        },
        nextQuest = {
            questClass = "frostivus_quest_destroy_snow_makers",
            allPlayers = true
        }
    },
    nil,
    QuestBase
)

function frostivus_quest_kill_roshan:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit ~= nil and killedUnit:IsCreature() and killedUnit:GetUnitName() == "npc_frostivus_boss_roshan" then
        self:ModifyValue("frostivus_quest_goal_kill_roshan", 1)
    end
end

function frostivus_quest_kill_roshan:OnDestroy()
    -- adavnce to next stage
    GM:SetStage(1)
end

return frostivus_quest_kill_roshan
