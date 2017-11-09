local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

frostivus_building_destroy = class({})

function frostivus_building_destroy:OnSpellStart()
  local caster = self:GetCaster()
  self:Refund()
  caster:Kill(self, caster)
end

-- FUN WITH L00PS
function frostivus_building_destroy:Refund()
  local caster = self:GetCaster()
  local plyID = caster:GetPlayerOwnerID()
  local casterName = caster:GetUnitName()
  -- get cost
  local costs = self:GetTotalCost(casterName, 0, 0)
  local baseCost = BuildingKV:GetRequirements(casterName)
  costs.gold = costs.gold + baseCost.GoldCost
  costs.lumber = costs.lumber + baseCost.LumberCost
  DeepPrintTable(costs)
  local percentage = caster:GetHealthPercent() / 100
  PlayerResource:ModifyLumber(plyID, costs.lumber * percentage)
  PlayerResource:ModifyGold(plyID, costs.gold * percentage)
end

-- this will confuse me so much in 2 days
function frostivus_building_destroy:GetTotalCost(name, goldCost, lumberCost)
  for unitName, unitData in pairs(unitKV) do
    local upgradeName = BuildingKV:GetUpgradeName(unitName)
    if upgrade and upgradeName == name then
      local requirements = BuildingKV:GetRequirements(upgradeName)
      goldCost = goldCost + requirements.GoldCost
      lumberCost = lumberCost + requirements.LumberCost
      return self:GetTotalCost(unitName, goldCost, lumberCost)
    end
  end
  return {gold = goldCost, lumber = lumberCost, baseUnit = name}
end
