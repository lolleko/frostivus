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
    GameRules:GetGameModeEntity():SetContextThink("frostivus_quest_" .. name .. "_" .. plyID .. "_".. DoUniqueString(plyID), function()
      -- if the quest still exists fail it
      if questList[name] and questList[name] == quest then
        if questList[name].event then
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

GameMode.EventList = {
  {
    class = ZombieEvent,
    stages = {0, 1},
    cooldown = 1200,
    weight = 4,
  },
  {
    class = SkeletonArmyEvent,
    stages = {0},
    cooldown = 900,
    weight = 6,
  },
  {
    class = ItemDrop,
    stages = {0, 1, 2},
    cooldown = 1200,
    weight = 4,
  },
  {
    class = GreevilsOnTheRun,
    stages = {0, 1, 2},
    cooldown = 1200,
    weight = 3,
  }
}

function GameMode:InitQuests()
  -- world event schduling
  -- start first event after 5-10 minutes
  --
  GameRules:GetGameModeEntity():SetContextThink("NextEventSchedule", function() return self:ScheduleNextEvent() end, RandomInt(300, 600))
end

function GameMode:ScheduleNextEvent()
  local readyEvents = {}
  local weights = {}
  for _, event in pairs(self.Events) do
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
  -- dispatch event
  GM:AddQuest(nextEvent.class)
  -- add cooldown to event
  nextEvent.cooldownEndTime = GameRules:GetGameTime() + nextEvent.cooldown
  return RandomInt(300, 600)
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
