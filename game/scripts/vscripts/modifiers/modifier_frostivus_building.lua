modifier_frostivus_building = class({})

function modifier_frostivus_building:OnCreated(e)
end

function modifier_frostivus_building:IsPurgable()
	return false
end

function modifier_frostivus_building:IsHidden()
	return true
end

function modifier_frostivus_building:OnDestroy(data)
  if IsServer() then
    -- we have to remove point simple obstrucitons immediatly becasue they are buggy as fuck
    for _, child in pairs(self:GetParent():GetChildren()) do
      if child:GetClassname() == "point_simple_obstruction" then
        SafeRemoveEntity(child)
      end
    end
	end
end
