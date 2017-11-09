CDOTA_PlayerResource:AddPlayerData("QuestList", NETWORKVAR_TRANSMIT_STATE_PLAYER, {})

function CDOTA_PlayerResource:AddQuest(plyID, quest)
  local name = quest.name
  quest.plyID = plyID
  local questList = self:GetQuestList(plyID)
  questList[quest.name] = quest
  if quest.OnStart then
    quest:OnStart()
  end
  if quest.timeLimit then
    self:GetPlayer(plyID):SetContextThink("frostivus_quest_" .. name, function()
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
    PlayerResource:AddQuest(plyID, quest())
  end
end
