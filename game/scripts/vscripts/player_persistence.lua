if IsInToolsMode() then
    Convars:RegisterCommand(
        "frost_test_persistence_save",
        function(cmdName, plyID)
            plyID = tonumber(plyID)
            print("---SERIALIZING PLAYER " .. plyID .. " BUILDINGS---")
            PrintTable(PlayerResource:StorePlayer(plyID))
            print("---DONE SERIALIZING PLAYER " .. plyID .. " BUILDINGS---")
        end,
        "Test persistence",
        0
    )

    Convars:RegisterCommand(
        "frost_test_persistence_load",
        function(cmdName, plyID)
            plyID = tonumber(plyID)
            PlayerResource:LoadPlayer(plyID)
        end,
        "Test persistence",
        0
    )

    Convars:RegisterCommand(
        "frost_test_persistence_reset",
        function(cmdName, plyID)
            plyID = tonumber(plyID)
            PlayerResource:SetCGData(plyID, table.deepcopy(GM.CGDefaultData))
            PlayerResource:UpdatePersitenData(plyID)
            print("---DISCONNECT TO PERMANETLY RESET---")
        end,
        "Test persistence",
        0
    )
end

CDOTA_PlayerResource:AddPlayerData("LastSaveTime", NETWORKVAR_TRANSMIT_STATE_NONE, 60)

function CDOTA_PlayerResource:ProcessSaveRequest(eventSourceIndex, data)
    local plyID = data.PlayerID
    if not GM:IsPVPHome() or GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        self:SendCastError(plyID, "frostivus_hud_error_cant_save")
        return
    end
    if self:GetLastSaveTime(plyID) + 20 <= GameRules:GetGameTime() then
        self:SetLastSaveTime(plyID, GameRules:GetGameTime())
        self:StorePlayer(plyID)
        Say(self:GetPlayer(plyID), "[FT] Successfully saved data!", true)
    else
        self:SendCastError(plyID, "frostivus_hud_error_save_cooldown")
    end
end
CustomGameEventManager:RegisterListener(
    "playerRequestSave",
    function(...)
        PlayerResource:ProcessSaveRequest(...)
    end
)

function CDOTA_PlayerResource:ResetPlayer(plyID, softReset)
    local buildingList = self:GetBuildingList(plyID)
    -- overwrite or keep existing data
    local saveData = self:GetCGData(plyID)
    saveData.buildings = {}
    for k = #buildingList, 1, -1 do
        local unit = buildingList[k]
        if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() then
            table.remove(buildingList, k)
        else
            unit:RemoveSelf()
        end
    end
    if not softReset then
        saveData.hero = {}
        saveData.hero.xp = 0
        saveData.hero.level = 1
        saveData.hero.inventory = {}
        saveData.hero.gold = 0
        saveData.hero.lumber = 0
    else
        saveData.hero.xp = 0
        saveData.hero.level = 1
        saveData.hero.gold = math.ceil(saveData.hero.gold / 2)
        saveData.hero.lumber = math.ceil(saveData.hero.lumber / 2)
    end

    -- player is new again (gets quests again)
    saveData.activeQuests = {}
    saveData.newPlayer = true
    self:SetCGData(plyID, saveData)
    self:UpdatePersitenData(plyID)
end

function CDOTA_PlayerResource:StorePlayer(plyID)
    local buildingList = self:GetBuildingList(plyID)
    -- overwrite or keep existing data
    local saveData = self:GetCGData(plyID)
    saveData.buildings = {}
    local center = GM:GetBuildingCenter(plyID)
    for k = #buildingList, 1, -1 do
        local unit = buildingList[k]
        if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() then
            table.remove(buildingList, k)
        else
            -- dont save the tree and "units"
            if not unit:IsSpiritTree() and not tobool(unit.Building.IsUnit) then
                local bld = {}
                bld.unitName = unit:GetUnitName()
                local origin = unit:GetOrigin()
                bld.origin = {center.x - origin.x, center.y - origin.y, center.z - origin.z}
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
    for i = 0, 20 do
        local item = hero:GetItemInSlot(i)
        if item then
            table.insert(saveData.hero.inventory, item:GetAbilityName())
        end
    end

    saveData.hero.gold = hero:GetGold()
    saveData.hero.lumber = self:GetLumber(plyID)

    -- player isnt considered new after first save
    saveData.newPlayer = false

    -- save quests
    -- we could store the whole quest list
    -- but we will jsut store the names for now (progress will be reset)
    saveData.activeQuests = {}
    for questName, _ in pairs(self:GetQuestList(plyID)) do
        table.insert(saveData.activeQuests, questName)
    end
    self:SetCGData(plyID, saveData)
    self:UpdatePersitenData(plyID)
    UTIL_MessageText(plyID, "#frostivus_hud_error_save_completed", 255, 255, 255, 255)
end

function CDOTA_PlayerResource:LoadPlayer(plyID, hero)
    -- hero arg is required because GetSelectedHeroEntity isnt set when OnPlayerPickHero is called
    -- Maybe init player in OnHeroInGame
    hero = hero or PlayerResource:GetSelectedHeroEntity(plyID)
    local saveData = self:GetCGData(plyID)
    local center = GM:GetBuildingCenter(plyID)
    -- load buidligns
    for _, building in pairs(saveData.buildings) do
        building.origin =
            Vector(center.x - building.origin[1], center.y - building.origin[2], center.z - building.origin[3])
        building.owner = hero
        building.skipAnimation = true
        self:SpawnBuilding(plyID, building.unitName, building)
    end
    -- load hero
    for i = 1, saveData.hero.level - 1 do
        hero:HeroLevelUp(false)
    end
    hero:AddExperience(saveData.hero.xp, 0, false, false)
    for _, item in pairs(saveData.hero.inventory) do
        hero:AddItemByName(item)
    end
    if GM:IsPVPHome() then
        hero:ModifyGold(saveData.hero.gold, true, DOTA_ModifyGold_Unspecified)
        self:ModifyLumber(plyID, saveData.hero.lumber)
    end
    -- load quest
    if GM:IsPVPHome() then
        for _, questName in pairs(saveData.activeQuests) do
            PlayerResource:AddQuest(hero:GetPlayerOwnerID(), QuestList[questName])
        end
        if saveData.newPlayer then
            PlayerResource:AddQuest(hero:GetPlayerOwnerID(), QuestList["frostivus_quest_starter_kill_enemies"])
        end
    end
end
