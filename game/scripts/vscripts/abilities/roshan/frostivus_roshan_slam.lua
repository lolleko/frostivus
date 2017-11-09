frostivus_roshan_slam = class({})

function frostivus_roshan_slam:OnSpellStart()
  local caster = self:GetCaster()

  local targets = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster:GetOrigin(),
    nil,
    self:GetSpecialValueFor("radius"),
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    0,
    FIND_ANY_ORDER,
    false
  )

  for _, target in pairs(targets) do
    -- check if target is building (dont apply knock backs to buildings)
    if not target:IsBuilding() then
      ApplyKnockback(target, caster:GetOrigin(), self:GetSpecialValueFor("knockback_duration"), self:GetSpecialValueFor("knockback_distance"), 64)
    end
    ApplyDamage({
      victim = target,
      attacker = caster,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = DAMAGE_TYPE_MAGICAL,
    })
  end

  ParticleManager:CreateParticle("particles/neutral_fx/roshan_slam.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
end

function frostivus_roshan_slam:GetCastAnimation()
  return ACT_DOTA_CAST_ABILITY_3
end
