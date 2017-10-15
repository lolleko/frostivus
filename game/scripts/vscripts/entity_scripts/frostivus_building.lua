local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

function Spawn(entityKV)
  AddSpawnProperty(thisEntity, "IsWall", "bool", false, entityKV)
  AddSpawnProperty(thisEntity, "IsSpawner", "bool", false, entityKV)
  AddSpawnProperty(thisEntity, "SpawnerScaleUnits", "bool", false, entityKV)
  AddSpawnProperty(thisEntity, "IsUpgradable", "bool", false, entityKV)
  AddSpawnProperty(thisEntity, "UpgradeName", "string", "", entityKV)
  AddSpawnProperty(thisEntity, "SpawnerInitialGoal", "entity", nil, entityKV)
  AddSpawnProperty(thisEntity, "SpawnerAllowControl", "bool", false, entityKV)

  AddSpawnProperty(thisEntity, "ResourceLumberCapacity", "number", 0, entityKV)
  AddSpawnProperty(thisEntity, "ResourceGoldCapacity", "number", 0, entityKV)

  AddSpawnProperty(thisEntity, "ResourceAcceptGold", "bool", false, entityKV)
  AddSpawnProperty(thisEntity, "ResourceAcceptLumber", "bool", false, entityKV)

  if thisEntity.IsWall then
    -- create wall reated things
    thisEntity.connectors = {}
  	thisEntity:SetContextThink( "WallRenderThink", function() return thisEntity:WallRenderThink() end, 0)

    function thisEntity:WallRenderThink()

  		local adjacentCreatures = Entities:FindAllByClassnameWithin( "npc_dota_creature", self:GetOrigin(), 644 )
  		local adjacentWalls = {}
  		for _, creature in pairs( adjacentCreatures ) do
  			if string.match( creature:GetUnitName(), "npc_frostivus_wall" ) and ( creature ~= self ) then
  				table.insert( adjacentWalls, creature )
  			end
  		end

  		for _, wall in pairs( adjacentWalls ) do
  			-- ugly as hell (recode maybe?)
  			local pos
  			local slot
  			if wall:GetOrigin() == self:GetOrigin() + Vector( -128, 128, 0 ) then
  				pos = self:GetOrigin() + Vector( -64, 64, 0 )
  				slot = 1
  			elseif wall:GetOrigin() == self:GetOrigin() + Vector( 0, 128, 0 ) then
  				pos = self:GetOrigin() + Vector( 0, 64, 0 )
  				slot = 2
  			elseif wall:GetOrigin() == self:GetOrigin() + Vector( 128, 128, 0 ) then
  				pos = self:GetOrigin() + Vector( 64, 64, 0 )
  				slot = 3
  			elseif wall:GetOrigin() == self:GetOrigin() + Vector( -128, 0, 0 ) then
  				pos = self:GetOrigin() + Vector( -64, 0, 0 )
  				slot = 4
  			elseif wall:GetOrigin() == self:GetOrigin() + Vector( -64, 128, 0 ) then
  				pos = self:GetOrigin() + Vector( -32, 64, 0 )
  				slot = 5
  			elseif wall:GetOrigin() == self:GetOrigin() + Vector( 64, 128, 0 ) then
  				pos = self:GetOrigin() + Vector( 32, 64, 0 )
  				slot = 6
  			elseif wall:GetOrigin() == self:GetOrigin() + Vector( -128, 64, 0 ) then
  				pos = self:GetOrigin() + Vector( -64, 32, 0 )
  				slot = 7
  			elseif wall:GetOrigin() == self:GetOrigin() + Vector( 128, 64, 0 ) then
  				pos = self:GetOrigin() + Vector( 64, 32, 0 )
  				slot = 8
  			end

  			if slot and pos and not self.connectors[ slot ] then
  				if slot == 2 or slot == 4 then
  					-- randomize the position a bit
  					pos = pos + Vector(RandomFloat(-8, 8), RandomFloat(-8, 8), RandomFloat(-8, 0))
  				end

  				local ent = SpawnEntityFromTableSynchronous("prop_dynamic", {model = self:GetModelName(), origin = pos})
  				ent:SetModelScale( 0.875 )
  				ent:SetParent( self, "attach_hitloc" )

  				self.connectors[ slot ] = ent

  				if slot == 1 or slot == 3 then
  					ent:SetAngles(0, 45, 0)
  				end
  			end

  		end

  		return 2
  	end
  end
  if thisEntity.IsSpawner then
    thisEntity.SpawnerUnits = {}
    for _, unitData in pairs(unitKV[thisEntity:GetUnitName()].SpawnerUnits) do
      local unitDataExt = table.merge({}, unitData)
      unitDataExt.NextSpawnTime = GameRules:GetGameTime() + unitDataExt.Interval
      unitDataExt.SpawnedUnits = {}
      table.insert(thisEntity.SpawnerUnits, unitDataExt)
    end
    thisEntity:SetContextThink("SpawnerThink", function() return thisEntity:SpawnerThink() end, 0)
    function thisEntity:SpawnerThink()
      for _, unitData in pairs(self.SpawnerUnits) do
        if unitData.NextSpawnTime <= GameRules:GetGameTime() then
          for k, unit in pairs(unitData.SpawnedUnits) do
            if not IsValidEntity(unit) or not unit:IsAlive() then
              table.remove(unitData.SpawnedUnits, k)
            end
          end
          if not unitData.MaxAlive or #unitData.SpawnedUnits < unitData.MaxAlive then
              -- do spawning
              CreateUnitByNameAsync(unitData.UnitName, self:GetOrigin(), true, self:GetOwner(), self:GetOwner(), self:GetTeam(), function(unit)
                unit.OriginalSpawnPoint = self
                if self.SpawnerInitialGoal then
                  unit:SetInitialGoalEntity(self.SpawnerInitialGoal)
                end
                if self.SpawnerAllowControl then
                  unit:SetContextThink("SetControllableByPlayer", function()
                    unit:SetControllableByPlayer(self:GetPlayerOwnerID(), true)
                  end, 0)
                end
                table.insert(unitData.SpawnedUnits, unit)
              end)
              unitData.NextSpawnTime = GameRules:GetGameTime() + unitData.Interval
          end
        end
      end
      return 1
    end
  end

  function thisEntity:OnConstructionCompleted()
    local ownerID = self:GetPlayerOwnerID()
    PlayerResource:SetLumberCapacity(ownerID, PlayerResource:GetLumberCapacity(ownerID) + self.ResourceLumberCapacity)
    PlayerResource:SetGoldCapacity(ownerID, PlayerResource:GetGoldCapacity(ownerID) + self.ResourceGoldCapacity)
  end
end
