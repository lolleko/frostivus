function Spawn( entityKV )
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
