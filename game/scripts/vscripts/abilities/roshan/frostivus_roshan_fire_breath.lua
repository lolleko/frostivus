frostivus_roshan_fire_breath = class({})

function frostivus_roshan_fire_breath:OnSpellStart()
    self.currentAngle = 80
    self.nextParticle = 2
end

function frostivus_roshan_fire_breath:OnChannelThink(interval)
    local caster = self:GetCaster()
    local forward = caster:GetForwardVector()
    local direction = RotatePosition(forward, QAngle(0, self.currentAngle, 0), Vector(0, 0, 0))
    direction.z = 0
    direction = direction:Normalized()
    -- spawn projectile
    if self.nextParticle == 0 then
        local distance = self:GetSpecialValueFor("distance")
        ProjectileManager:CreateLinearProjectile(
            {
                Ability = self,
                --EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
                EffectName = "particles/boss/roshan/dragon_knight_breathe_fire.vpcf",
                vSpawnOrigin = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc")),
                fDistance = distance,
                fStartRadius = 40,
                fEndRadius = 80,
                Source = caster,
                bHasFrontalCone = false,
                bReplaceExisting = false,
                iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
                iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                bDeleteOnHit = false,
                vVelocity = direction * 800,
                bProvidesVision = false
            }
        )
        self.nextParticle = 3
        DebugDrawLine(
            caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc")),
            caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_hitloc")) + direction * distance,
            255,
            0,
            0,
            false,
            2
        )
    end
    self.nextParticle = self.nextParticle - 1
    self.currentAngle = self.currentAngle + (interval / self:GetChannelTime()) * 160
end

function frostivus_roshan_fire_breath:GetPlaybackRateOverride()
    return 1
end

function frostivus_roshan_fire_breath:OnProjectileHit(target, location)
    if target and IsValidEntity(target) then
        ApplyDamage(
            {
                victim = target,
                attacker = self:GetCaster(),
                damage = self:GetSpecialValueFor("damage"),
                damage_type = DAMAGE_TYPE_MAGICAL
            }
        )
    else
        -- we reached or destination kill our particle_folder
    end
end
