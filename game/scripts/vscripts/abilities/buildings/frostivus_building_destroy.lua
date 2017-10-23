local unitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
local investmentsKV = LoadKeyValues("scripts/npc/frostivus_investments.txt")

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
  for _, investment in pairs(investmentsKV) do
    if investment.UnitName == costs.baseUnit then
      if investment.GoldCost then
        costs.gold = costs.gold + investment.GoldCost
      end

      if investment.LumberCost then
        costs.lumber = costs.lumber + investment.LumberCost
      end
    end
  end
  local percentage = caster:GetHealthPercent() / 100
  PlayerResource:ModifyLumber(plyID, costs.lumber * percentage)
  PlayerResource:ModifyGold(plyID, costs.gold * percentage, false, 0)
end

-- this will confuse me so much in 2 days
function frostivus_building_destroy:GetTotalCost(name, goldCost, lumberCost)
  for unitName, unitData in pairs(unitKV) do
    local upgrade = BuildingKV:GetUpgrade(unitName)
    if upgrade and upgrade.UnitName == name then
      goldCost = goldCost + upgrade.GoldCost
      lumberCost = lumberCost + upgrade.LumberCost
      return self:GetTotalCost(unitName, goldCost, lumberCost)
    end
  end
  return {gold = goldCost, lumber = lumberCost, baseUnit = name}
end
