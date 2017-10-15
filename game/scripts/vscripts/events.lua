function GameMode:OnPlayerPickHero(data)
  local spawn = Entities:FindByName(nil, "spirit_tree_spawn0")
  local hero = EntIndexToHScript(data.heroindex)
  PlayerResource:SpawnBuilding(hero:GetPlayerOwnerID(), "npc_frostivus_spirit_tree", {origin = spawn:GetOrigin(), sizeX = 2, sizeY = 2, owner = hero})
end
