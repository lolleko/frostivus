CDOTA_PlayerResource:AddPlayerData("QuestList", NETWORKVAR_TRANSMIT_STATE_PLAYER, {})

function CDOTA_PlayerResource:AddQuest(plyID, quest, force)
  local questList = self:GetQuestList(plyID)
  -- prevent adding the same quest multiple times by default
  if not force and questList[quest.name] then return end
  local name = quest.name
  quest.plyID = plyID
  questList[quest.name] = quest
  if quest.OnStart then
    quest:OnStart()
  end
  if quest.timeLimit then
    GameRules:GetGameModeEntity():SetContextThink("frostivus_quest_" .. name .. "_" .. plyID .. "_".. DoUniqueString(name), function()
      -- if the quest still exists fail it
      if questList[name] and questList[name] == quest then
        if questList[name].dontFailOnTime then
          quest:Complete()
        else
          quest:Fail(name)
        end
      end
    end, quest.timeLimit)
  end
  CustomGameEventManager:Send_ServerToPlayer(self:GetPlayer(plyID), "frostivus_quest_added", quest)
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
  GameRules:GetGameModeEntity():SetContextThink("NextEventSchedule", function() return self:ScheduleNextEvent() end, RandomInt(450, 600))
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

function GameMode:AddQuest(questClass)
  for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
    PlayerResource:AddQuest(plyID, questClass())
  end
end

function GameMode:ModifyQuestValue(questName, valueName, change)
  for _, plyID in pairs(PlayerResource:GetAllPlaying()) do
    local quest = PlayerResource:GetQuest(plyID, questName)
    if quest then
      quest:ModifyValue(valueName, change)
    end
  end
end

QuestBase = class({
  constructor = function(self)
    -- we need to copy tables
    if self.rewards then
      self.rewards = table.deepcopy(self.rewards)
    end
    if self.values then
      self.values = table.deepcopy(self.values)
    end
    if self.valueGoals then
      self.valueGoals = table.deepcopy(self.valueGoals)
    end
  end
})

function QuestBase:ModifyValue(valueName, change)
  self:SetValue(valueName, self:GetValue(valueName) + change)
end

function QuestBase:GetValue(valueName)
  return self.values[valueName]
end

function QuestBase:SetValue(valueName, value)
  self.values[valueName] = value
  local updateData = {questName = self.name, valueName = valueName, value = value}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_update", updateData)

  if self:IsCompleted() then
    self:Complete()
  end
end

function QuestBase:Complete()
  local completeData = {questName = self.name, rewards = self.rewards}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_completed", completeData)
  if self.rewards then
    if self.rewards.resource then
      for resourceName, amount in pairs(self.rewards.resource) do
        if resourceName == "xp" then
          PlayerResource:GetSelectedHeroEntity(self.plyID):AddExperience(amount, 0, false, false)
        elseif resourceName == "gold" then
          PlayerResource:ModifyGold(self.plyID, amount)
        elseif resourceName == "lumber" then
          PlayerResource:ModifyLumber(self.plyID, amount)
        end
      end
    end
  end
  self:OnCompleted()
  self:Destroy()
end

function QuestBase:Destroy()
  local destroyData = {questName = self.name}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_destroyed", destroyData)
  PlayerResource:RemoveQuest(self.plyID, self.name)
  self:OnDestroy()
end

function QuestBase:Fail()
  local completeData = {questName = self.name}
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(self.plyID), "frostivus_quest_failed", completeData)
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

function QuestBase:OnStart()

end

function QuestBase:OnFailed()

end

function QuestBase:OnCompleted()

end

function QuestBase:OnDestroy()

end
