modifier_provides_fow_position = class({})

function modifier_provides_fow_position:OnCreated(data)
	if SERVER then
		local parent = self:GetParent()
		CreateUnitByNameAsync("npc_frostivus_vision_dummy", parent:GetAbsOrigin(), false, parent, parent, data.team or parent:GetTeam(), function(unit)
		  unit:SetParent(parent, "attach_hitloc")
		  unit:SetNightTimeVisionRange(15)
		  unit:SetDayTimeVisionRange(15)
		  unit:AddEffects(EF_NODRAW)
			unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
		end)
	end
end

--------------------------------------------------------------------------------

function modifier_provides_fow_position:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_provides_fow_position:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_provides_fow_position:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_provides_fow_position:GetModifierProvidesFOWVision( params )
	return 1
end
