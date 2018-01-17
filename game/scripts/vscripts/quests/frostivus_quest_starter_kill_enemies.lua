local frostivus_quest_starter_kill_enemies =
    class(
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
        events = {
            "entity_killed"
        },
        nextQuest = {
            questClass = "frostivus_quest_starter_lumber_camp",
            onlyOnCompleted = false
        }
    },
    nil,
    QuestBase
)

function frostivus_quest_starter_kill_enemies:OnStart()
    if GM:IsCoop() then
        BroadcastMessage("#frostivus_notification_act1", 9, true)
    end
end

function frostivus_quest_starter_kill_enemies:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit ~= nil and killedUnit:IsCreature() and (killedUnit:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS) then
        self:ModifyValue("frostivus_quest_goal_killed_enemies", 1)
    end
end

return frostivus_quest_starter_kill_enemies
