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
