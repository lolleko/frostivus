local frostivus_event_item_drop =
    class(
    {
        name = "frostivus_event_item_drop",
        values = {
            frostivus_quest_goal_intercept_carrier = 0
        },
        valueGoals = {
            frostivus_quest_goal_intercept_carrier = 1
        },
        events = {
            "entity_killed"
        }
    },
    nil,
    QuestBase
)

function frostivus_event_item_drop:OnStart()
    local routes = {
        {spawn = "item_drop_carrier_spawn1", goal = "item_drop_carrier_spawn3"},
        {spawn = "item_drop_carrier_spawn3", goal = "item_drop_carrier_spawn4"},
        {spawn = "item_drop_carrier_spawn4", goal = "item_drop_carrier_spawn2"},
        {spawn = "item_drop_carrier_spawn2", goal = "item_drop_carrier_spawn1"}
    }
    local route = routes[math.random(#routes)]
    local spawn = Entities:FindByName(nil, route.spawn)
    local goal = Entities:FindByName(nil, route.goal)
    CreateUnitByNameAsync(
        "npc_frostivus_item_drop_carrier",
        spawn:GetOrigin(),
        true,
        nil,
        nil,
        DOTA_TEAM_BADGUYS,
        function(unit)
            GM:ScaleUnit(unit)
            unit:AddNewModifier(unit, nil, "modifier_provides_fow_position", {team = DOTA_TEAM_GOODGUYS})
            AddFOWViewer(DOTA_TEAM_GOODGUYS, spawn:GetOrigin() + Vector(0, 0, 30), 1000, 2, false)
            AddFOWViewer(DOTA_TEAM_GOODGUYS, goal:GetOrigin() + Vector(0, 0, 30), 1000, 2, false)
            GM:SendMinimapPing(spawn:GetOrigin())
            unit:SetContextThink(
                "disseaperWhenClose",
                function()
                    unit:MoveToPosition(goal:GetOrigin())
                    if (goal:GetOrigin() - unit:GetOrigin()):Length2D() <= 500 then
                        unit.preventDrop = true
                        unit:Kill(nil, unit)
                    end
                    return 5
                end,
                2
            )
        end
    )
end

function frostivus_event_item_drop:OnEntityKilled(event)
    local items = {
        {
            "item_blight_stone",
            "item_boots",
            "item_wind_lace",
            "item_ring_of_protection",
            "item_ring_of_regen",
            "item_sobi_mask",
            "item_blades_of_attack",
            "item_gloves",
            "item_robe",
            "item_belt_of_strength",
            "item_boots_of_elves",
            "item_chainmail",
            "item_void_stone",
            "item_ring_of_health",
            "item_helm_of_iron_will",
            "item_energy_booster",
            "item_vitality_booster",
            "item_lifesteal",
            "item_broadsword"
        },
        {
            "item_broadsword",
            "item_javelin",
            "item_platemail",
            "item_ogre_axe",
            "item_blade_of_alacrity",
            "item_staff_of_wizardry"
        },
        {
            "item_javelin",
            "item_platemail",
            "item_talisman_of_evasion",
            "item_hyperstone",
            "item_ultimate_orb",
            "item_demon_edge",
            "item_mystic_staff",
            "item_reaver",
            "item_eagle",
            "item_relic"
        }
    }
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if
        killedUnit ~= nil and killedUnit:IsCreature() and
            (killedUnit:GetUnitName() == "npc_frostivus_item_drop_carrier" and not killedUnit.preventDrop)
     then
        local stageItems = items[GM:GetStage() + 1]
        local item = stageItems[math.random(#stageItems)]
        killedUnit:DropItemAtPosition(killedUnit:GetOrigin(), item)
        self:ModifyValue("frostivus_quest_goal_intercept_carrier", 1)
    end
end

return frostivus_event_item_drop
