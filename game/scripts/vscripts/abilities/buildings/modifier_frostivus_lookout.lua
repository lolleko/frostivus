modifier_frostivus_lookout = class({})

function modifier_frostivus_lookout:OnCreated(e)
	if IsServer() then
		self:GetParent().LookoutSentry = EntIndexToHScript(e.lookoutSentry)
	end
end

function modifier_frostivus_lookout:IsHidden()
	return true
end

function modifier_frostivus_lookout:OnDestroy(data)
  -- Lets build a pyramid
  if IsServer() then
		SafeRemoveEntityDelayed(self:GetParent().LookoutSentry, 4)
	end
end
