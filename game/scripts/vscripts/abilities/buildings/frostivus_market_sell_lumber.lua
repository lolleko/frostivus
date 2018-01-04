frostivus_market_sell_lumber = class({})

function frostivus_market_sell_lumber:OnSpellStart()
    local caster = self:GetCaster()
    local plyID = caster:GetPlayerOwnerID()
    local income = self:GetSpecialValueFor("gold_income")

    if PlayerResource:GetLumber(plyID) >= 100 then
        PlayerResource:ModifyGold(plyID, income)
        PlayerResource:ModifyLumber(plyID, -100)
    else
        PlayerResource:SendCastError(plyID, "frostivus_hud_error_not_enough_lumber")
    end
end
