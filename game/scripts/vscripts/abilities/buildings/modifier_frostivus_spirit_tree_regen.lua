modifier_frostivus_spirit_tree_regen = class({})

function modifier_frostivus_spirit_tree_regen:OnCreated(e)
	local smoke = ParticleManager:CreateParticle("particles/abilities/smoke_screen/smoke_screen.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

	self.radius = self:GetAbility():GetSpecialValueFor("radius")

	ParticleManager:SetParticleControl(smoke, 0, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(smoke, 1, Vector(self.radius, self.radius, self.radius))
end

function modifier_frostivus_spirit_tree_regen:IsHidden()
	return true
end

function modifier_frostivus_spirit_tree_regen:IsAura()
	return true
end

function modifier_frostivus_spirit_tree_regen:GetModifierAura()
	return "modifier_frostivus_spirit_tree_regen_aura"
end

function modifier_frostivus_spirit_tree_regen:GetAuraRadius()
	return self.radius
end

function modifier_frostivus_spirit_tree_regen:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_frostivus_spirit_tree_regen:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

modifier_frostivus_spirit_tree_regen_aura = class({})

function modifier_frostivus_spirit_tree_regen_aura:OnCreated(e)
	self.healthRegen = self:GetAbility():GetSpecialValueFor("health_regeneration")
  self.manaRegen = self:GetAbility():GetSpecialValueFor("mana_regeneration")
  self.bonusArmor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_frostivus_spirit_tree_regen_aura:IsDebuff()
	return false
end

function modifier_frostivus_spirit_tree_regen_aura:GetEffectName()
  return "particles/econ/events/winter_major_2017/radiant_fountain_regen_wm07_lvl3.vpcf"
end

function modifier_frostivus_spirit_tree_regen_aura:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_frostivus_spirit_tree_regen_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

function modifier_frostivus_spirit_tree_regen_aura:GetModifierConstantHealthRegen()
	return self.healthRegen
end

function modifier_frostivus_spirit_tree_regen_aura:GetModifierConstantManaRegen()
  return self.manaRegen
end

function modifier_frostivus_spirit_tree_regen_aura:GetModifierPhysicalArmorBonus()
  return self.bonusArmor
end
