local frostivus_quest_kill_storegga =
    class(
    {
        name = "frostivus_quest_kill_storegga",
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
                xp = 2500
            }
        },
        events = {
            "entity_killed"
        }
    },
    nil,
    QuestBase
)

function frostivus_quest_kill_storegga:OnStart()
    local spawn = Entities:FindByName(nil, "storegga_spawn"):GetOrigin()
    CreateUnitByNameAsync(
        "npc_frostivus_boss_storegga",
        spawn,
        true,
        nil,
        nil,
        DOTA_TEAM_BADGUYS,
        function(unit)
        end
    )
    GM:SendMinimapPing(spawn)
    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawn + Vector(0, 0, 30), 800, 120, false)
end

function frostivus_quest_kill_storegga:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if killedUnit ~= nil and killedUnit:IsCreature() and killedUnit:GetUnitName() == "npc_frostivus_boss_storegga" then
        self:ModifyValue("frostivus_quest_goal_kill_storegga", 1)
    end
end

function frostivus_quest_kill_storegga:OnDestroy()
    GM:SetStage(2)
    -- TODO remove (end game later)
    GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
end

return frostivus_quest_kill_storegga
