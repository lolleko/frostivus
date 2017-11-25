frostivus_healer_heal = class({})

LinkLuaModifier("modifier_frostivus_healer_heal_caster", "abilities/buildings/frostivus_healer_heal.lua", LUA_MODIFIER_MOTION_NONE)

function frostivus_healer_heal:OnSpellStart()
  local target = self:GetCursorTarget()
  local caster = self:GetCaster()
  local particle = ParticleManager:CreateParticle("particles/building/heal_ray.vpcf", PATTACH_POINT_FOLLOW, caster)
  ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "ray_origin", caster:GetOrigin(), true)
  ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
  self.particle = particle
  self.second = 0
end

function frostivus_healer_heal:OnChannelThink(interval)
  local target = self:GetCursorTarget()
  local caster = self:GetCaster()
  if self.second >= 1 then
    target:Heal(self:GetSpecialValueFor("health_per_second") * caster:GetLevel(), caster)
    self.second = 0
  end
  self.second = self.second + interval
end

function frostivus_healer_heal:OnChannelFinish()
  ParticleManager:DestroyParticle(self.particle, false)
  ParticleManager:ReleaseParticleIndex(self.particle)
end

modifier_frostivus_healer_heal_caster = class({})

function modifier_frostivus_healer_heal_caster:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
    MODIFIER_PROPERTY_DISABLE_TURNING
	}

	return funcs
end

function modifier_frostivus_healer_heal_caster:GetModifierIgnoreCastAngle()
  return 1
end

function modifier_frostivus_healer_heal_caster:GetModifierDisableTurning()
  return 1
end
