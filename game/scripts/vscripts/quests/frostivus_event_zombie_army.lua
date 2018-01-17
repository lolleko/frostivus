local frostivus_event_zombie_army =
    class(
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
        events = {
            "entity_killed"
        },
        timeLimit = 150
    },
    nil,
    QuestBase
)

function frostivus_event_zombie_army:OnCreated()
    self.tombsToSpawn = 4
    self.valueGoals.frostivus_quest_goal_destroy_tombstones = self.tombsToSpawn
    self.timeLimit = self.tombsToSpawn * 40
end

function frostivus_event_zombie_army:OnStart()
    BroadcastMessage("#frostivus_event_zombie_army", 5, false)

    local spawnPoints = Entities:FindAllByName("zombie_army_toombstone_spawn")
    table.shuffle(spawnPoints)
    local tombsToSpawn = self.tombsToSpawn
    for _, spawnPoint in pairs(spawnPoints) do
        if tombsToSpawn ~= 0 then
            CreateUnitByNameAsync(
                "npc_frostivus_zombie_army_tombstone",
                spawnPoint:GetOrigin(),
                true,
                nil,
                nil,
                DOTA_TEAM_BADGUYS,
                function(unit)
                    AddFOWViewer(
                        DOTA_TEAM_GOODGUYS,
                        spawnPoint:GetOrigin() + Vector(0, 0, 30),
                        100,
                        self.timeLimit,
                        false
                    )
                    GM:ScaleUnit(unit)
                    GM:SendMinimapPing(spawnPoint:GetOrigin())
                    unit:AddNewModifier(unit, nil, "modifier_kill", {duration = self.timeLimit})
                end
            )
            tombsToSpawn = tombsToSpawn - 1
        end
    end
end

function frostivus_event_zombie_army:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if
        killedUnit ~= nil and killedUnit:IsCreature() and
            (killedUnit:GetUnitName() == "npc_frostivus_zombie_army_tombstone")
     then
        self:ModifyValue("frostivus_quest_goal_destroy_tombstones", 1)
    end
end

return frostivus_event_zombie_army
