modifier_frostivus_resource_carry = class({})

function modifier_frostivus_resource_carry:OnCreated(data)
  if IsServer() then
    local parent = self:GetParent()
    local model
    local modelScale = 1
    self.stackCount = 5
    self.stackSize = 100
    local offsets
    self.IsLumber = data.IsLumber
    self.IsGold = data.IsGold
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
    local origin = parent:GetOrigin()
    for _, offset in pairs(offsets) do
      local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, scale = modelScale, origin = origin})
      local ang = parent:GetAnglesAsVector()
      if RandomInt(0, 1) == 0 then
        ang.y = ang.y + 180
      end
      prop:FollowEntity(parent, false)
      prop:SetOrigin(origin + offset)
      prop:SetAngles(ang.x, ang.y, ang.z)
    end
    parent:AddNewModifier(parent, nil, "modifier_frostivus_resource_gather", {duration = 5})
    parent:SetMustReachEachGoalEntity(false)
    parent:SetInitialGoalEntity(nil)
    self:StartIntervalThink(2.5)
  end
end

function modifier_frostivus_resource_carry:OnIntervalThink()
  if IsServer() then
    local parent = self:GetParent()
    local plyID = parent:GetPlayerOwnerID()
    local units = FindUnitsInRadius(
        parent:GetTeam(),
        parent:GetOrigin(),
        nil,
        400,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    for k, unit in pairs(units) do
      if (unit.ResourceAcceptGold and self.IsGold) then
        PlayerResource:ModifyGold(plyID, self.stackCount * self.stackSize , true, 0)
        parent:RemoveSelf()
      elseif(unit.ResourceAcceptLumber and self.IsLumber) then
        PlayerResource:ModifyLumber(plyID, self.stackCount * self.stackSize)
        parent:RemoveSelf()
      end
    end
  end
end

function modifier_frostivus_resource_carry:CheckState()

end
