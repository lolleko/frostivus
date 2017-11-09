LinkLuaModifier("modifier_frostivus_roshan_immortality", "abilities/roshan/frostivus_roshan_immortality.lua", LUA_MODIFIER_MOTION_NONE)

frostivus_roshan_immortality = class({})

function frostivus_roshan_immortality:IsPassive()
  return true
end


function frostivus_roshan_immortality:GetIntrinsicModifierName()
  return "modifier_frostivus_roshan_immortality"
end

modifier_frostivus_roshan_immortality = class({})

function modifier_frostivus_roshan_immortality:OnCreated()

end

function modifier_frostivus_roshan_immortality:DeclareFunctions()
  return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_frostivus_roshan_immortality:OnDeath(data)
  -- Lets build a pyramid
  if IsServer() then
    if data.unit == self:GetParent() then
      local aegis = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/props_gameplay/aegis.vmdl", origin = self:GetParent():GetOrigin(), DefaultAnim = "aegis_idle"})
      local duration = RandomInt(10, 15)
      local timer = ParticleManager:CreateParticle("particles/boss/roshan/roshan_timer_simple.vpcf", PATTACH_ABSORIGIN, aegis)
      ParticleManager:SetParticleControl(timer, 0, aegis:GetOrigin() + Vector(0, 0, 200))
      ParticleManager:ReleaseParticleIndex(timer)
      aegis:SetContextThink("respawn_roshan", function()
        CreateUnitByNameAsync("npc_frostivus_boss_roshan", aegis:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS, function(unit)
          unit:RemoveAbility("frostivus_roshan_immortality")
          local spawnParticle = ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf", PATTACH_ABSORIGIN, unit)
          ParticleManager:SetParticleControl(spawnParticle, 0, unit:GetOrigin())
          ParticleManager:ReleaseParticleIndex(spawnParticle)
        end)
        aegis:RemoveSelf()
      end, duration)
    end
  end
end
