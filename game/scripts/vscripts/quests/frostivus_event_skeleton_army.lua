local frostivus_event_skeleton_army =
    class(
    {
        name = "frostivus_event_skeleton_army",
        values = {
            --frostivus_quest_goal_kill_boss_skeleton = 0,
            frostivus_quest_goal_kill_skeletons = 0
        },
        valueGoals = {
            --frostivus_quest_goal_kill_boss_skeleton = 1,
            frostivus_quest_goal_kill_skeletons = 0
        },
        rewards = {
            resource = {
                gold = 100,
                lumber = 100,
                xp = 80
            }
        },
        events = {
            "entity_killed"
        }
    },
    nil,
    QuestBase
)

function frostivus_event_skeleton_army:OnCreated()
    self.skeletonsToSpawnPerLine = 4
    self.valueGoals.frostivus_quest_goal_kill_skeletons = self.skeletonsToSpawnPerLine * 4
end

function frostivus_event_skeleton_army:OnStart()
    BroadcastMessage("#frostivus_event_skeleton_army", 5, false)

    local functionSpawnLine =
        function(corner1, corner2)
        corner1 = Entities:FindByName(nil, corner1):GetOrigin()
        corner2 = Entities:FindByName(nil, corner2):GetOrigin()
        local line = (corner1 - corner2)
        local padding = line / self.skeletonsToSpawnPerLine
        for i = 1, self.skeletonsToSpawnPerLine do
            local randomOffset = RandomVector(200)
            randomOffset.z = 0
            local spawn = corner2 + padding * i + randomOffset
            CreateUnitByNameAsync(
                "npc_frostivus_skeleton_army_skeleton",
                spawn,
                true,
                nil,
                nil,
                DOTA_TEAM_BADGUYS,
                function(unit)
                    GM:ScaleUnit(unit)
                    AddFOWViewer(DOTA_TEAM_GOODGUYS, spawn + Vector(0, 0, 30), 100, 2, false)
                    GM:SendMinimapPing(spawn)
                end
            )
        end
    end
    -- clock wise
    functionSpawnLine("skeleton_army_corner_top_left", "skeleton_army_corner_top_right")
    functionSpawnLine("skeleton_army_corner_top_right", "skeleton_army_corner_bottom_right")
    functionSpawnLine("skeleton_army_corner_bottom_right", "skeleton_army_corner_bottom_left")
    functionSpawnLine("skeleton_army_corner_bottom_left", "skeleton_army_corner_top_left")
end

function frostivus_event_skeleton_army:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if
        killedUnit ~= nil and killedUnit:IsCreature() and
            (killedUnit:GetUnitName() == "npc_frostivus_skeleton_army_skeleton")
     then
        self:ModifyValue("frostivus_quest_goal_kill_skeletons", 1)
    end
end

return frostivus_event_skeleton_army
