(function () {
  // on reconnect load quests from player.questlist
  var questPanels = {}
  var questList = Players.GetQuestList(Players.GetLocalPlayer())
  for (var questName in questList) {
    AddQuest(questList[questName])
  }
  function AddQuest (e) {
    var questPanel = CreateLayout($('#QuestListRoot'), e.name, 'file://{resources}/layout/custom_game/quest/quest.xml')
    questPanel.LoadQuest(e)
    questPanels[e.name] = questPanel
    // some special cases for start quests
    if (e.name === 'frostivus_quest_starter_lumber_camp') {
      $.GetContextPanel().FindChildTraverse('BuildingsButton').AddClass('Highlight')
    }
  }
  GameEvents.Subscribe('frostivus_quest_added', AddQuest)

  GameEvents.Subscribe('frostivus_quest_update', function (e) {
    var questPanel = questPanels[e.questName]
    questPanel.SetValue(e.valueName, e.value)
  })

  GameEvents.Subscribe('frostivus_quest_completed', function (e) {
    var questPanel = questPanels[e.questName]
    questPanel.Complete()
  })

  GameEvents.Subscribe('frostivus_quest_failed', function (e) {
    var questPanel = questPanels[e.questName]
    questPanel.Fail()
  })

  GameEvents.Subscribe('frostivus_quest_destroyed', function (e) {
    var questPanel = questPanels[e.questName]
    questPanel.Destroy()
  })
}())
