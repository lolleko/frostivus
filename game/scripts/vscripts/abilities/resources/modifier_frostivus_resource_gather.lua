modifier_frostivus_resource_gather = class({})

function modifier_frostivus_resource_gather:OnCreated(data)
	self.IsLumber = data.IsLumber
	self.IsGold = data.IsGold
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
		local goal
		if self.IsLumber then
			goal = PlayerResource:FindBuildingByName(parent:GetPlayerOwnerID(), "npc_frostivus_lumber_storage")
		elseif self.IsGold then
			goal = PlayerResource:FindBuildingByName(parent:GetPlayerOwnerID(), "npc_frostivus_gold_storage")
		end
		if not goal then
			goal = GM:GetSpiritTree(parent:GetPlayerOwnerID())
		end
		parent:MoveToPosition(goal:GetOrigin())
  end
end
