if IsInToolsMode() then
	Convars:RegisterCommand("frost_test_persistence_save", function(cmdName, plyID)
		plyID = tonumber(plyID)
    print("---SERIALIZING PLAYER " .. plyID .. " BUILDINGS---")
		PrintTable(PlayerResource:StorePlayer(plyID))
    print("---DONE SERIALIZING PLAYER " .. plyID .. " BUILDINGS---")
	end, "Test persistence", 0)

  Convars:RegisterCommand("frost_test_persistence_load", function(cmdName, plyID)
    plyID = tonumber(plyID)
    PlayerResource:LoadPlayer(plyID)
  end, "Test persistence", 0)
end

function CDOTA_PlayerResource:StorePlayer(plyID)
  local buildingList = self:GetBuildingList(plyID)
  local saveData = {}
  saveData.buildings = {}
  for k, unit in pairs(buildingList) do
    if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() then
      table.remove(buildingList, k)
    else
			if not unit:IsSpiritTree() then
				local bld = {}
	      bld.unitName = unit:GetUnitName()
	      local origin = unit:GetOrigin()
	      bld.origin = {origin.x, origin.y, origin.z}
	      bld.rotation = unit:GetAngles().y
	      table.insert(saveData.buildings, bld)
			end
    end
  end
  saveData.hero = {}
  local hero = self:GetSelectedHeroEntity(plyID)
  saveData.hero.xp = hero:GetCurrentXP()
  saveData.hero.level = hero:GetLevel()
  saveData.hero.inventory = {}
  for i=0, 20 do
    local item = hero:GetItemInSlot(i)
    if item then
      table.insert(saveData.hero.inventory, item:GetAbilityName())
    end
  end

  self:SetCGData(plyID, saveData)
  self:UpdatePersitenData(plyID)
end

function CDOTA_PlayerResource:LoadPlayer(plyID, owner)
	-- owner arg ioos required because GetSelectedHeroEntity isnt set yet if OnPlayerPickHero is called
  local saveData = self:GetCGData(plyID)
  for _, building in pairs(saveData.buildings) do
    building.origin = Vector(building.origin[1], building.origin[2], building.origin[3])
		building.owner = owner
    self:SpawnBuilding(plyID, building.unitName, building)
  end
end
