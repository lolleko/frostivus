function Spawn()
  --thisEntity:SetContextThink("BasicAIThink", function()
  --    thisEntity:MoveToPositionAggressive(Vector(0, 0, 0))
  --end, 1)
  --thisEntity:SetContextThink("BasicAIThink", BasicAIThink, 0.1)
end

function BasicAIThink()
  if not thisEntity:GetAggroTarget() then
    local rand = RandomInt(1, 3)
    local interval = 2
    -- attack walls or random defense buzildings
    if rand == 1 then
      local wall Entities:GetRandomCloseBuildingWithName(thisEntity:GetOrigin(), "npc_frostivus_defense")
      if wall then
        thisEntity:MoveToTargetToAttack(wall)
        return interval
      end
      rand = rand + 1
    end
    -- attack tree if wall not closed
    if rand == 2 then
      -- get closest tree
      local tree = Entities:GetClosestFromTable(thisEntity:GetOrigin(), Entities:FindAllBuildingsWithName("npc_frostivus_spirit_tree"))
      if tree and GridNav:CanFindPath(thisEntity:GetOrigin(), tree:GetOrigin()) then
        thisEntity:MoveToTargetToAttack(tree)
        return interval
      end
      rand = rand + 1
    end
    -- attack move to center of map
    if rand == 3 then
      thisEntity:MoveToPositionAggressive(Vector(0, 0, 0))
      return interval
    end
  end
  return 4
end
