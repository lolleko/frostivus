modifier_frostivus_lookout = class({})

function modifier_frostivus_lookout:OnCreated(e)
    if IsServer() then
        self:GetParent().LookoutSentry = EntIndexToHScript(e.lookoutSentry)
    end
end

function modifier_frostivus_lookout:IsPurgable()
    return false
end

function modifier_frostivus_lookout:IsHidden()
    return true
end

function modifier_frostivus_lookout:OnDestroy(data)
    if IsServer() then
        SafeRemoveEntityDelayed(self:GetParent().LookoutSentry, 4)
    end
end
