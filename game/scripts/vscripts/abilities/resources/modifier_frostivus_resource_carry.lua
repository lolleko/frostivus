modifier_frostivus_resource_carry = class({})

function modifier_frostivus_resource_carry:OnCreated(data)
  if IsServer() then
    local parent = self:GetParent()
    local model
    local modelScale = 1
    self.stackCount = 5
    self.stackSize = RandomInt(15 + parent:GetLevel()^4, 20 + parent:GetLevel()^4)
    -- double income in pvp
    if GM:IsPVP() and not GM:IsPVPHome() then
      self.stackSize = self.stackSize * 2
    end
    local offsets
    self.IsLumber = data.IsLumber
    self.IsGold = data.IsGold
    -- TODO rework prop placement
    if data.IsLumber then
      model = "models/props_nature/log001.vmdl"
      modelScale = 0.3
      offsets = {
        Vector(0, 0, 81) + parent:GetForwardVector() * 5,
        Vector(0, 0, 81) + parent:GetForwardVector() * -5,
        Vector(0, 0, 81) + parent:GetForwardVector() * -15,
        Vector(0, 0, 88) + parent:GetForwardVector() * 0,
        Vector(0, 0, 88) + parent:GetForwardVector() * -10,
      }
    elseif data.IsGold then


    end
    if offsets then
      local origin = parent:GetOrigin()
      for _, offset in pairs(offsets) do
        local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {model = model, scale = modelScale, origin = origin})
        local ang = parent:GetAnglesAsVector()
        if RandomInt(0, 1) == 0 then
          ang.y = ang.y + 180
        end
        --prop:FollowEntity(parent, false)
        if parent:HasFlyMovementCapability() then
          offset = offset + Vector(0, 0, 10)
        end
        prop:SetOrigin(origin + offset)

        prop:SetAngles(ang.x, ang.y, ang.z)
        prop:SetParent(parent, "saddleBag2_end_A_L")
      end
    end
    parent:AddNewModifier(parent, nil, "modifier_frostivus_resource_gather", {duration = 5, IsLumber = self.IsLumber, IsGold = self.IsGold})
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
      if unit.bAcceptGold and self.IsGold then
        PlayerResource:ModifyGold(plyID, self.stackCount * self.stackSize)
        parent:RemoveSelf()
      elseif unit.bAcceptLumber and self.IsLumber then
        PlayerResource:ModifyLumber(plyID, self.stackCount * self.stackSize)
        parent:RemoveSelf()
      end
    end
  end
end

function modifier_frostivus_resource_carry:CheckState()

end
