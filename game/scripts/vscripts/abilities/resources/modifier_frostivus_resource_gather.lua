modifier_frostivus_resource_gather = class({})

function modifier_frostivus_resource_gather:OnCreated(data)
  -- body...
end

function modifier_frostivus_resource_gather:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_BLIND] = true,
	}
	return state
end

function modifier_frostivus_resource_gather:OnDestroy()
  if IsServer() then
    local parent = self:GetParent()
		local lumberStorage = PlayerResource:FindBuildingByName(parent:GetPlayerOwnerID(), "npc_frostivus_lumber_storage")
		if not lumberStorage then
			lumberStorage = PlayerResource:FindBuildingByName(parent:GetPlayerOwnerID(), "npc_frostivus_spirit_tree")
		end
    parent:MoveToPosition(lumberStorage:GetOrigin())
  end
end
