frostivus_unit_destroy = class({})

function frostivus_unit_destroy:OnSpellStart()
    local caster = self:GetCaster()
    caster:Kill(self, caster)
end
