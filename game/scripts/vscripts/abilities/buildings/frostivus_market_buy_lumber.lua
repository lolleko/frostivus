frostivus_market_buy_lumber = class({})

function frostivus_market_buy_lumber:OnSpellStart()
  local caster = self:GetCaster()
  local plyID = caster:GetPlayerOwnerID()
  local cost = self:GetSpecialValueFor("gold_cost")

  if PlayerResource:GetGold(plyID) >= cost then
    PlayerResource:ModifyGold(plyID, -cost)
    PlayerResource:ModifyLumber(plyID, 100)
  else
    PlayerResource:SendCastError(plyID, "frostivus_hud_error_not_enough_gold")
  end
end
