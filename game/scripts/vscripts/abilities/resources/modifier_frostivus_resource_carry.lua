modifier_frostivus_resource_carry = class({})

function modifier_frostivus_resource_carry:OnCreated(data)
  local parent = self:GetParent()
  local model
  local modelScale = 1
  local count = 1
  local offsets
  if data.IsLumber then
    model = "models/props_nature/log001.vmdl"
    modelScale = 0.3
    offsets = {
      Vector(0, 0, 81) + parent:GetForwardVector() * 5,
      Vector(0, 0, 81) + parent:GetForwardVector() * -5,
      Vector(0, 0, 81) + parent:GetForwardVector() * -15,
    }
  elseif data.IsGold then


  end
  print(parent:GetEntityIndex())
  if parent.GetOrigin then
    local origin = parent:GetOrigin()
    for _, offset in pairs(offsets) do
      local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, scale = modelScale, origin = origin})
      prop:FollowEntity(parent, false)
      prop:SetOrigin(origin + offset)
    end
  end
end

function modifier_frostivus_resource_carry:CheckState()

end
