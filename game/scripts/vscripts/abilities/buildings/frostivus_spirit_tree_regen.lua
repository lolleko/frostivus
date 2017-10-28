LinkLuaModifier("modifier_frostivus_spirit_tree_regen", "abilities/buildings/modifier_frostivus_spirit_tree_regen.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_frostivus_spirit_tree_regen_aura", "abilities/buildings/modifier_frostivus_spirit_tree_regen.lua", LUA_MODIFIER_MOTION_NONE)

frostivus_spirit_tree_regen = class({})

function frostivus_spirit_tree_regen:IsPassive()
  return true
end


function frostivus_spirit_tree_regen:GetIntrinsicModifierName()
  return "modifier_frostivus_spirit_tree_regen"
end
