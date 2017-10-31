local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

function Spawn(entityKV)

  thisEntity.Building = BuildingKV:GetBuilding(thisEntity:GetUnitName())
  AddSpawnProperty(thisEntity, "LumberCapacity", "number", 0, thisEntity.Building)
  AddSpawnProperty(thisEntity, "GoldCapacity", "number", 0, thisEntity.Building)

  AddSpawnProperty(thisEntity, "IsWall", "bool", false, thisEntity.Building, "bIsWall")
  AddSpawnProperty(thisEntity, "IsLookout", "bool", false, thisEntity.Building, "bIsLookout")
  AddSpawnProperty(thisEntity, "IsSpawner", "bool", false, thisEntity.Building, "bIsSpawner")

  AddSpawnProperty(thisEntity, "AcceptGold", "bool", false, thisEntity.Building, "bAcceptGold")
  AddSpawnProperty(thisEntity, "AcceptLumber", "bool", false, thisEntity.Building, "bAcceptLumber")

  local ownerID = thisEntity:GetPlayerOwnerID()

  if ownerID ~= -1 then
    PlayerResource:SetLumberCapacity(ownerID, PlayerResource:GetLumberCapacity(ownerID) + thisEntity.LumberCapacity)
    PlayerResource:SetGoldCapacity(ownerID, PlayerResource:GetGoldCapacity(ownerID) + thisEntity.GoldCapacity)
  end

  if not string.match(thisEntity:GetUnitName(), "npc_frostivus_spirit_tree") then
    thisEntity:AddAbility("frostivus_building_upgrade")
    thisEntity:AddAbility("frostivus_building_destroy")
  end

  function thisEntity:IsBuilding()
    return true
  end

  if thisEntity.Building.DynamicModels then
    for _, dynMdl in pairs(thisEntity.Building.DynamicModels) do
      local scale = dynMdl.ModelScale or 1
      local origin = thisEntity:GetOrigin() + tovector(dynMdl.Offset)
      local color
      if dynMdl.color then
        -- TODO somehow retrieve playercolor
        --if dynMdl.color == "!PlayerColor" then
          --color = PlayerResource:GetCustomPlayerColor(ownerID)
        --end
      end
      local propDyn = SpawnEntityFromTableSynchronous("prop_dynamic", {model = dynMdl.Model, origin = origin, angles = tovector(dynMdl.Angles), DefaultAnim = dynMdl.Sequence, rendercolor = color})
      propDyn:SetModelScale(scale)
      propDyn:SetParent(thisEntity, nil)
    end
  end

  function thisEntity:IsWall()
    return thisEntity.bIsWall
  end

  function thisEntity:AcceptGold()
    return thisEntity.bAcceptGold
  end

  function thisEntity:AcceptLumber()
    return thisEntity.bAcceptLumber
  end

  -- expose this function
  function thisEntity:OnConstructionCompleted()
    local template = Entities:FindByName(nil, "tree_shop_template")
    local newshop = SpawnEntityFromTableSynchronous("trigger_shop", {origin = thisEntity:GetAbsOrigin(), shoptype = 1, model=template:GetModelName()})
  end

  if thisEntity.bIsWall then
    -- create wall reated things
    thisEntity.connectors = {}
  	thisEntity:SetContextThink( "WallRenderThink", WallRenderThink, 0)
  end
  if thisEntity.bIsSpawner then
    thisEntity.SpawnerUnits = {}
    for _, unitData in pairs(thisEntity.Building.Spawner.Units) do
      local unitDataExt = table.merge({}, unitData)
      -- randomize first interval a bit
      local initalDelay = unitDataExt.InitialDelay or 0
      unitDataExt.NextSpawnTime = GameRules:GetGameTime() + initalDelay + RandomInt(0, unitDataExt.Interval / 4)
      unitDataExt.InitialGoal = Entities:FindByName(nil, unitData.InitialGoal)
      unitDataExt.Spawnpoint = Entities:FindByName(nil, unitData.Spawnpoint) or thisEntity
      unitDataExt.SpawnedUnits = {}
      table.insert(thisEntity.SpawnerUnits, unitDataExt)
    end
    thisEntity:SetContextThink("SpawnerThink", SpawnerThink, 0)
  end
end

function WallRenderThink()

  local adjacentCreatures = Entities:FindAllByClassnameWithin( "npc_dota_creature", thisEntity:GetOrigin(), 644 )
  local adjacentWalls = {}
  for _, creature in pairs( adjacentCreatures ) do
    if string.match( creature:GetUnitName(), "npc_frostivus_defense_wall" ) and ( creature ~= thisEntity ) then
      table.insert( adjacentWalls, creature )
    end
  end

  for _, wall in pairs( adjacentWalls ) do
    -- ugly as hell (recode maybe?)
    local pos
    local slot
    if wall:GetOrigin() == thisEntity:GetOrigin() + Vector( -128, 128, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( -64, 64, 0 )
      slot = 1
    elseif wall:GetOrigin() == thisEntity:GetOrigin() + Vector( 0, 128, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( 0, 64, 0 )
      slot = 2
    elseif wall:GetOrigin() == thisEntity:GetOrigin() + Vector( 128, 128, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( 64, 64, 0 )
      slot = 3
    elseif wall:GetOrigin() == thisEntity:GetOrigin() + Vector( -128, 0, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( -64, 0, 0 )
      slot = 4
    elseif wall:GetOrigin() == thisEntity:GetOrigin() + Vector( -64, 128, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( -32, 64, 0 )
      slot = 5
    elseif wall:GetOrigin() == thisEntity:GetOrigin() + Vector( 64, 128, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( 32, 64, 0 )
      slot = 6
    elseif wall:GetOrigin() == thisEntity:GetOrigin() + Vector( -128, 64, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( -64, 32, 0 )
      slot = 7
    elseif wall:GetOrigin() == thisEntity:GetOrigin() + Vector( 128, 64, 0 ) then
      pos = thisEntity:GetOrigin() + Vector( 64, 32, 0 )
      slot = 8
    end

    if slot and pos and not thisEntity.connectors[ slot ] then
      if slot == 2 or slot == 4 then
        -- randomize the position a bit
        pos = pos + Vector(RandomFloat(-8, 8), RandomFloat(-8, 8), RandomFloat(-8, 0))
      end

      local ent = SpawnEntityFromTableSynchronous("prop_dynamic", {model = thisEntity:GetModelName(), origin = pos})
      ent:SetModelScale( 0.875 )
      ent:SetParent( thisEntity, "attach_hitloc" )

      thisEntity.connectors[ slot ] = ent

      if slot == 1 or slot == 3 then
        ent:SetAngles(0, 45, 0)
      end
    end

  end

  return 2
end

function SpawnerThink()
  for _, unitData in pairs(thisEntity.SpawnerUnits) do
    if unitData.NextSpawnTime <= GameRules:GetGameTime() then
      for k, unit in pairs(unitData.SpawnedUnits) do
        if not IsValidEntity(unit) or not unit:IsAlive() then
          table.remove(unitData.SpawnedUnits, k)
        end
      end
      if not unitData.MaxAlive or #unitData.SpawnedUnits < unitData.MaxAlive then
          -- do spawning
          local spawnPoint = thisEntity:GetOrigin()
          if unitData.Spawnpoint then
              spawnPoint = unitData.Spawnpoint:GetOrigin()
          end
          CreateUnitByNameAsync(unitData.UnitName, spawnPoint, true, thisEntity:GetOwner(), thisEntity:GetOwner(), thisEntity:GetTeam(), function(unit)
            if unitData.InitialGoal then
              if unitData.MoveToGoal then
                unit:SetContextThink("initalOrderDelayed", function()
                  unit:MoveToPosition(unitData.InitialGoal:GetOrigin())
                end, 0.5)
              elseif unitData.MoveToGoalAggressive then
                unit:SetContextThink("initalOrderDelayed", function()
                  unit:MoveToPositionAggressive(unitData.InitialGoal:GetOrigin())
                end, 0.5)
              else
                unit:SetInitialGoalEntity(unitData.InitialGoal)
              end
            end
            if unitData.AllowControl then
              unit:SetContextThink("SetControllableByPlayer", function()
                unit:SetControllableByPlayer(thisEntity:GetPlayerOwnerID(), true)
              end, 0)
            end
            if unitData.ScaleUnits then
              local scalar = GM:GetDifficultyScalar()
              print(scalar)
              unit:SetMaxHealth(unit:GetMaxHealth() + math.floor(unit:GetMaxHealth() * scalar/800))
              unit:SetHealth(unit:GetMaxHealth())
              unit:SetPhysicalArmorBaseValue(unit:GetPhysicalArmorValue() + (unit:GetPhysicalArmorValue() * scalar/900))
              unit:SetBaseMagicalResistanceValue(unit:GetBaseMagicalResistanceValue() + (unit:GetBaseMagicalResistanceValue() * scalar/1000))
              unit:SetBaseDamageMin(unit:GetBaseDamageMin() + math.floor(unit:GetBaseDamageMin() * scalar/700))
              unit:SetBaseDamageMax(unit:GetBaseDamageMax() + math.floor(unit:GetBaseDamageMax() * scalar/700))
            end
            table.insert(unitData.SpawnedUnits, unit)
          end)
          unitData.NextSpawnTime = GameRules:GetGameTime() + unitData.Interval
      end
    end
  end
  return 1
end
