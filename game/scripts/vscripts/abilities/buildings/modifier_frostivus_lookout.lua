modifier_frostivus_lookout = class({})

function modifier_frostivus_lookout:OnCreated(e)
	if IsServer() then
		self.LookoutSentry = EntIndexToHScript(e.lookoutSentry)
	end
end

function modifier_frostivus_lookout:IsHidden()
	return true
end

function modifier_frostivus_lookout:OnDestroy(data)
  -- Lets build a pyramid
  if IsServer() then
		SafeRemoveEntityDelayed(self.LookoutSentry, 4)
	end
end
