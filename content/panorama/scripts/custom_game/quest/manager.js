(function () {
  var questPanels = {}
  GameEvents.Subscribe('frostivus_quest_added', function (e) {
    var questPanel = CreateLayout($('#QuestListRoot'), e.name, 'file://{resources}/layout/custom_game/quest/quest.xml')
    questPanel.LoadQuest(e)
    questPanels[e.name] = questPanel
  })

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
