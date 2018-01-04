local frostivus_quest_starter_gold_camp =
    class(
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
                xp = 100
            }
        },
        events = {
            "npc_spawned"
        }
    },
    nil,
    QuestBase
)

function frostivus_quest_starter_gold_camp:OnNPCSpawned(event)
    local spawnedUnit = EntIndexToHScript(event.entindex)
    if spawnedUnit ~= nil then
        if spawnedUnit:GetPlayerOwnerID() == self.plyID and spawnedUnit:GetUnitName() == "npc_frostivus_gold_camp_tier1" then
            self:ModifyValue("frostivus_quest_goal_gold_camp_constructed", 1)
        end
    end
end

function frostivus_quest_starter_gold_camp:OnDestroy()
    if not GM:IsPVP() and not GM.RoshQuestStarted then
        GM:AddQuest(QuestList.frostivus_quest_summon_roshan)
        GM.RoshQuestStarted = true
    end
end

return frostivus_quest_starter_gold_camp
