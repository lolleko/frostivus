local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

function Spawn(entityKV)

  thisEntity.Building = table.deepcopy(BuildingKV:GetBuilding(thisEntity:GetUnitName()))
  AddSpawnProperty(thisEntity, "LumberCapacity", "number", 0, thisEntity.Building)
  AddSpawnProperty(thisEntity, "GoldCapacity", "number", 0, thisEntity.Building)

  AddSpawnProperty(thisEntity, "IsWall", "bool", false, thisEntity.Building, "bIsWall")
  AddSpawnProperty(thisEntity, "IsLookout", "bool", false, thisEntity.Building, "bIsLookout")
  AddSpawnProperty(thisEntity, "IsDefense", "bool", false, thisEntity.Building, "bIsDefense")
  AddSpawnProperty(thisEntity, "IsSpiritTree", "bool", false, thisEntity.Building, "bIsSpiritTree")
  AddSpawnProperty(thisEntity, "IsSpawner", "bool", false, thisEntity.Building, "bIsSpawner")
  AddSpawnProperty(thisEntity, "ScaleUnit", "bool", false, thisEntity.Building, "bScaleUnit")

  AddSpawnProperty(thisEntity, "AcceptGold", "bool", false, thisEntity.Building, "bAcceptGold")
  AddSpawnProperty(thisEntity, "AcceptLumber", "bool", false, thisEntity.Building, "bAcceptLumber")

  local ownerID = thisEntity:GetPlayerOwnerID()

  if ownerID ~= -1 then
    PlayerResource:SetLumberCapacity(ownerID, PlayerResource:GetLumberCapacity(ownerID) + thisEntity.LumberCapacity)
    PlayerResource:SetGoldCapacity(ownerID, PlayerResource:GetGoldCapacity(ownerID) + thisEntity.GoldCapacity)
  end

  if not string.match(thisEntity:GetUnitName(), "npc_frostivus_spirit_tree") then
    if thisEntity.Building.Upgrade then
      thisEntity:AddAbility("frostivus_building_upgrade")
    end
    thisEntity:AddAbility("frostivus_building_destroy")
  end

  function thisEntity:IsBuilding()
    return true
  end

  function thisEntity:IsSpiritTree()
    return thisEntity.bIsSpiritTree
  end

  function thisEntity:IsDefense()
    return thisEntity.bIsDefense
  end

  function thisEntity:IsLookout()
    return thisEntity.bIsLookout
  end

  if thisEntity.Building.DynamicModels then
    for _, dynMdl in pairs(thisEntity.Building.DynamicModels) do
      local scale = dynMdl.ModelScale or 1
      local origin = thisEntity:GetOrigin() + tovector(dynMdl.Offset)
      local color
      if dynMdl.Color then
        -- TODO somehow retrieve playercolor
        if dynMdl.Color == "!PlayerColor" then
          color = PlayerResource:GetPlayerColor(ownerID)
        end
      end
      local propDyn = SpawnEntityFromTableSynchronous("prop_dynamic", {model = dynMdl.Model, origin = origin, angles = tovector(dynMdl.Angles), DefaultAnim = dynMdl.Sequence})
      if color then
        propDyn:SetRenderColor(color.x, color.y, color.z)
      end
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
    if thisEntity:GetUnitName() == "npc_frostivus_market_tier1" then
      local shopEnt = Entities:FindByName(nil, "market_shop_template")
      local newshop = SpawnEntityFromTableSynchronous('trigger_shop', {origin = thisEntity:GetAbsOrigin(), shoptype = 0, model = shopEnt:GetModelName(), parent = thisEntity})
    end
  end

  if thisEntity.bScaleUnit then
    GM:ScaleUnit(thisEntity)
  end

  if thisEntity.bIsWall then
    -- create wall reated things
    thisEntity.connectors = {}
  	thisEntity:SetContextThink( "WallRenderThink", WallRenderThink, 0)
  end
  if thisEntity.bIsSpawner then
    thisEntity:SetContextThink("SpawnerThinkInital", function ()
      thisEntity.SpawnerUnits = {}
      for _, unitData in pairs(thisEntity.Building.Spawner.Units) do
        local unitDataExt = table.deepcopy(unitData)
        -- randomize first interval a bit
        local initalDelay = unitDataExt.InitialDelay or 0
        unitDataExt.NextSpawnTime = GameRules:GetGameTime() + initalDelay
        unitDataExt.InitialGoal = Entities:FindByName(nil, unitData.InitialGoal)
        local goals = Entities:FindAllByName(unitData.InitialGoal)
        local minDist = -1
        local minGoal
        for _, goal in pairs(goals) do
          local dist = (thisEntity:GetOrigin() - goal:GetOrigin()):Length2D()
          if minDist == -1 or dist < minDist then
            minDist = dist
            minGoal = goal
          end
        end
        if #goals > 0 then
          unitDataExt.InitialGoal = minGoal
        end
        if unitData.Spawnpoint then
          unitDataExt.Spawnpoint = Entities:FindByName(nil, unitData.Spawnpoint) or thisEntity
        else
          unitDataExt.Spawnpoint = thisEntity
        end
        unitDataExt.SpawnedUnits = {}
        table.insert(thisEntity.SpawnerUnits, unitDataExt)
      end
      thisEntity:SetContextThink("SpawnerThink", SpawnerThink, 0)
    end, 0)
  end

  if thisEntity.Building.IsInvulnerable then
    thisEntity:AddNewModifier(thisEntity, nil, "modifier_invulnerable", {})
  end

  if thisEntity.Building.vscripts then
    local spawnFunc = LoadFunctionFromFile(thisEntity.Building.vscripts, "Spawn", getfenv(Spawn))
    spawnFunc(entityKV)
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
  local interval = 1
  local gameTime = GameRules:GetGameTime()
  for _, unitData in pairs(thisEntity.SpawnerUnits) do
    if unitData.NextSpawnTime <= gameTime then
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
            -- TODO the leveling is only used for resource drones
            -- TODO make more SOLID
            unit:CreatureLevelUp(thisEntity:GetLevel() - unit:GetLevel())
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
              GM:ScaleUnit(unit)
            end
            table.insert(unitData.SpawnedUnits, unit)
          end)
          unitData.NextSpawnTime = gameTime + unitData.Interval
      end
    elseif GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or (unitData.Stage and unitData.Stage > GM:GetStage()) then
      -- keep spawnDelay until stage is ready
      unitData.NextSpawnTime = gameTime + (unitData.InitialDelay or unitData.Interval)
    end
  end
  return interval
end
