modifier_frostivus_lookout = class({})

function modifier_frostivus_lookout:OnCreated(e)
	if IsServer() then
		self.LookoutSentry = EntIndexToHScript(e.lookoutSentry)
	end
end

function modifier_frostivus_lookout:OnDestroy()
	if IsServer() then
    SafeRemoveEntityDelayed(self.LookoutSentry, 3)
	end
end
