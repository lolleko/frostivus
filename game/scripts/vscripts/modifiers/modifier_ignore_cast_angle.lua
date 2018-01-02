modifier_ignore_cast_angle = class({})

function modifier_ignore_cast_angle:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_ignore_cast_angle:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_ignore_cast_angle:DeclareFunctions()
	local funcs =
	{
    MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
    MODIFIER_PROPERTY_DISABLE_TURNING
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_ignore_cast_angle:GetModifierIgnoreCastAngle( params )
	return 1
end

function modifier_ignore_cast_angle:GetModifierDisableTurning()
  return 1
end
