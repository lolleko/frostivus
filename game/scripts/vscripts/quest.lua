CDOTA_PlayerResource:AddPlayerData("QuestList", NETWORKVAR_TRANSMIT_STATE_PLAYER, {})

function CDOTA_PlayerResource:AddQuest(plyID, quest, allPlayers, force)
    -- all players share an instance if allplayer is not set we need to instanciate
    if not allPlayers then
        quest = quest(plyID)
    end
    local questList = self:GetQuestList(plyID)
    local name = quest:GetName()
    -- prevent adding the same quest multiple times by default
    if not force and questList[name] then
        return
    end
    questList[name] = quest
end

function CDOTA_PlayerResource:GetQuest(plyID, name)
    return self:GetQuestList(plyID)[name]
end

function CDOTA_PlayerResource:RemoveQuest(plyID, name)
    self:GetQuestList(plyID)[name] = nil
end

function GameMode:InitQuests()
    -- world event schduling
    -- start first event after 5-10 minutes
    --
    -- TODO respect pauses
    GameRules:GetGameModeEntity():SetContextThink(
        "NextEventSchedule",
        function()
            return self:ScheduleNextEvent()
        end,
        RandomInt(450, 600)
    )
end

function GameMode:ScheduleNextEvent()
    local readyEvents = {}
    local weights = {}
    for _, event in pairs(self.EventList) do
        if not event.cooldownEndTime or event.cooldownEndTime <= GameRules:GetGameTime() then
            local canHappenInCurrentStage = false
            for _, stage in ipairs(event.stages) do
                if stage == GM:GetStage() then
                    canHappenInCurrentStage = true
                end
            end
            if canHappenInCurrentStage then
                table.insert(readyEvents, event)
                table.insert(weights, event.weight)
            end
        end
    end
    local weightSum = 0
    for _, v in ipairs(weights) do
        weightSum = weightSum + v
    end
    local rnd = RandomInt(0, weightSum)
    local nextEvent
    for _, event in ipairs(readyEvents) do
        if not nextEvent then
            if rnd < event.weight then
                nextEvent = event
            end
            rnd = event.weight
        end
    end
    if nextEvent then
        -- dispatch event
        GM:AddQuest(nextEvent.class)
        -- add cooldown to event
        nextEvent.cooldownEndTime = GameRules:GetGameTime() + nextEvent.cooldown
        local nextSchedule = RandomInt(300, 600)
        if nextEvent.small then
            nextSchedule = nextSchedule / 2
        end
        return nextSchedule
    end
end

function GameMode:AddQuest(questClass, dontShare)
    if dontShare then
        for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
            PlayerResource:AddQuest(plyID, questClass)
        end
    else
        local instance = questClass()
        for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
            PlayerResource:AddQuest(plyID, instance, true)
        end
    end
end

function GameMode:ModifyQuestValue(questName, valueName, change)
    for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
        local quest = PlayerResource:GetQuest(plyID, questName)
        if quest then
            quest:ModifyValue(valueName, change)
            -- if the quest is shared bail after one change
            if not quest.plyID then return end
        end
    end
end

QuestBase =
    class(
    {
        constructor = function(self, plyID)
            -- we need to copy tables in case we want to run quests more tahn once
            self.plyID = plyID
            if self.rewards then
                self.rewards = table.deepcopy(self.rewards)
            end
            if self.values then
                self.values = table.deepcopy(self.values)
            end
            if self.valueGoals then
                self.valueGoals = table.deepcopy(self.valueGoals)
            end
            self.statics = {}

            self:OnCreated()
            self:Start()
        end
    }
)

function QuestBase:SendQuestEvent(name, data)
    if self.plyID then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), name, data)
    else
        CustomGameEventManager:Send_ServerToAllClients(name, data)
    end
end

function QuestBase:ExecFuncForPlayer(func)
    if self.plyID then
        func(self.plyID)
    else
        for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
            func(plyID)
        end
    end
end

function QuestBase:GetName()
    return self.name
end

function QuestBase:ModifyValue(valueName, change)
    self:SetValue(valueName, self:GetValue(valueName) + change)
end

function QuestBase:GetValue(valueName)
    return self.values[valueName]
end

function QuestBase:SetValue(valueName, value)
    self.values[valueName] = value
    local updateData = {questName = self.name, valueName = valueName, value = value}
    self:SendQuestEvent("frostivus_quest_update", updateData)
    if self:IsCompleted() then
        self:Complete()
    end
end

function QuestBase:Start()
    if self.timeLimit then
        local plyID = self.plyID or "ALLPLAYERS"
        local name = self.name
        GameRules:GetGameModeEntity():SetContextThink(
            "frostivus_quest_" .. name .. "_" .. plyID .. "_" .. DoUniqueString(name),
            function()
                if self.dontFailOnTime then
                    self:Complete()
                else
                    self:Fail()
                end
            end,
            self.timeLimit
        )
    end
    self:SendQuestEvent("frostivus_quest_added", self)
    -- init goals
    if self.events then
        self.eventHandles = {}
        for _, event in pairs(self.events) do
            if event == "entity_killed" then
                local handle = ListenToGameEvent("entity_killed", self.OnEntityKilled, self)
                table.insert(self.eventHandles, handle)
            end
            if event == "npc_spawned" then
                local handle = ListenToGameEvent("npc_spawned", self.OnNPCSpawned, self)
                table.insert(self.eventHandles, handle)
            end
        end
    end
    self:OnStart()
end

function QuestBase:Complete()
    local completeData = {questName = self.name, rewards = self.rewards}
    self:SendQuestEvent("frostivus_quest_completed", completeData)
    if self.rewards then
        if self.rewards.resource then
            self:ExecFuncForPlayer(
                function(plyID)
                    for resourceName, amount in pairs(self.rewards.resource) do
                        if resourceName == "xp" then
                            PlayerResource:GetSelectedHeroEntity(plyID):AddExperience(amount, 0, false, false)
                        elseif resourceName == "gold" then
                            PlayerResource:ModifyGold(plyID, amount)
                        elseif resourceName == "lumber" then
                            PlayerResource:ModifyLumber(plyID, amount)
                        end
                    end
                end
            )
        end
    end
    self:OnCompleted()
    self:Destroy()
end

function QuestBase:Destroy()
    local destroyData = {questName = self.name}
    self:SendQuestEvent("frostivus_quest_destroyed", destroyData)
    self:ExecFuncForPlayer(
        function(plyID)
            PlayerResource:RemoveQuest(plyID, self.name)
        end
    )
    if self.eventHandles then
        for _, handle in pairs(self.eventHandles) do
            StopListeningToGameEvent(handle)
        end
    end
    if self.nextQuest then
        local questClass = QuestList[self.nextQuest.questClass]
        if self.nextQuest.onlyOnCompleted then
            if self:IsCompleted() then
                if self.nextQuest.allPlayers then
                    GM:AddQuest(questClass)
                else
                    PlayerResource:AddQuest(self.plyID, questClass)
                end
            end
        else
            if self.nextQuest.allPlayers then
                GM:AddQuest(questClass)
            else
                PlayerResource:AddQuest(self.plyID, questClass)
            end
        end
    end
    self:OnDestroy()
end

function QuestBase:Fail()
    local completeData = {questName = self.name}
    self:SendQuestEvent("frostivus_quest_failed", completeData)
    self:OnFailed()
    self:Destroy()
end

function QuestBase:IsCompleted()
    local completed = true
    for valueName, value in pairs(self.values) do
        if value < self.valueGoals[valueName] then
            completed = false
        end
    end
    return completed
end

function QuestBase:OnCreated()
end

function QuestBase:OnStartOnce()
end

function QuestBase:OnStart()
end

function QuestBase:OnFailed()
end

function QuestBase:OnCompleted()
end

function QuestBase:OnDestroy()
end

-- event funcs
function QuestBase:OnEntityKilled()
end

function QuestBase:OnNPCSpawned()
end
