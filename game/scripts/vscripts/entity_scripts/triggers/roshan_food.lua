function Spawn(entityKV)
    thisEntity.foodCount = 0
    thisEntity.requiredFood = 10
    thisEntity.resurrectDuration = 3.5
    thisEntity.foodList = {}
    thisEntity.foodCompleted = false
    thisEntity.resurrectParticles = {}
end

function OnStartTouch(data)
    if thisEntity.foodCompleted then
        return
    end
    local hero = data.activator
    local item = hero:FindItemInInventory("item_roshan_food_chicken")
    while item do
        hero:RemoveItem(item)
        item = hero:FindItemInInventory("item_roshan_food_chicken")
        SpawnFood("models/props_gameplay/chicken.vmdl", "chicken_idle")
        GM:ModifyQuestValue("frostivus_quest_summon_roshan", "frostivus_quest_goal_summon_roshan_chicken", 1)
    end
    item = hero:FindItemInInventory("item_roshan_food_cheese")
    while item do
        hero:RemoveItem(item)
        item = hero:FindItemInInventory("item_roshan_food_cheese")
        SpawnFood("models/props_gameplay/cheese.vmdl")
        GM:ModifyQuestValue("frostivus_quest_summon_roshan", "frostivus_quest_goal_summon_roshan_cheese", 1)
    end
end

function SpawnFood(modelName, sequence)
    local spawnPoint = Entities:FindByName(nil, "roshan_food_pos" .. thisEntity.foodCount)
    local propDyn =
        SpawnEntityFromTableSynchronous(
        "prop_dynamic",
        {
            model = modelName,
            origin = spawnPoint:GetOrigin(),
            angles = Vector(0, RandomInt(0, 360), 0),
            DefaultAnim = sequence
        }
    )
    table.insert(thisEntity.foodList, propDyn)
    thisEntity.foodCount = thisEntity.foodCount + 1
    if thisEntity.foodCount == thisEntity.requiredFood then
        thisEntity.foodCompleted = true
        local skull = Entities:FindByName(nil, "roshan_bones_skull")
        for _, food in pairs(thisEntity.foodList) do
            local particle =
                ParticleManager:CreateParticle("particles/building/heal_ray.vpcf", PATTACH_POINT_FOLLOW, food)
            ParticleManager:SetParticleControlEnt(
                particle,
                0,
                food,
                PATTACH_POINT_FOLLOW,
                "attach_hitloc",
                food:GetOrigin(),
                true
            )
            ParticleManager:SetParticleControlEnt(
                particle,
                1,
                skull,
                PATTACH_POINT_FOLLOW,
                "attach_hitloc",
                skull:GetOrigin(),
                true
            )
            table.insert(thisEntity.resurrectParticles, particle)
        end
        thisEntity.resurrectStartTime = GameRules:GetGameTime()
        thisEntity:SetContextThink("RessurrectThink", RessurrectThink, 0)
    end
end

function RessurrectThink()
    -- THIS is harcoded so any chance to one variable will likelöy require chances
    -- to all anim related variables
    -- not enough time for something more fancy
    if not GameRules:IsGamePaused() then
        local bones = Entities:FindAllByName("roshan_bones")
        local ang
        for _, bone in pairs(bones) do
            bone:SetOrigin(bone:GetOrigin() + Vector(0, 0, 1.3))
            ang = bone:GetAngles()
            bone:SetAngles(ang.x - 1.2, ang.y, ang.z)
        end
        local skull = Entities:FindByName(nil, "roshan_bones_skull")
        skull:SetOrigin(skull:GetOrigin() + Vector(0, 0, 1.3) - (skull:GetForwardVector() * 1.2))
        if thisEntity.resurrectStartTime + thisEntity.resurrectDuration <= GameRules:GetGameTime() then
            -- Spawn rosh
            -- local spawnParticle = ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf", PATTACH_ABSORIGIN, skull)
            -- ParticleManager:SetParticleControl(spawnParticle, 0, GetGroundPosition(skull:GetOrigin(), skull))
            -- ParticleManager:ReleaseParticleIndex(spawnParticle)
            CreateUnitByNameAsync(
                "npc_frostivus_boss_roshan",
                GetGroundPosition(skull:GetOrigin(), skull),
                true,
                nil,
                nil,
                DOTA_TEAM_BADGUYS,
                function(unit)
                    local spawnParticle =
                        ParticleManager:CreateParticle(
                        "particles/neutral_fx/roshan_spawn.vpcf",
                        PATTACH_ABSORIGIN,
                        unit
                    )
                    ParticleManager:SetParticleControl(spawnParticle, 0, unit:GetOrigin())
                    ParticleManager:ReleaseParticleIndex(spawnParticle)
                end
            )
            -- Cleanup
            for _, particle in pairs(thisEntity.resurrectParticles) do
                ParticleManager:DestroyParticle(particle, false)
                ParticleManager:ReleaseParticleIndex(particle)
            end
            for _, bone in pairs(bones) do
                bone:RemoveSelf()
            end
            skull:RemoveSelf()
            for _, food in pairs(thisEntity.foodList) do
                food:RemoveSelf()
            end
            return
        end
    end
    return 1 / 20
end
