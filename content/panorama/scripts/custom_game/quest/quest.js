(function () {
  var goalPanels = {}
  $.GetContextPanel().LoadQuest = function (quest) {
    $('#Name').text = quest.name
    $('#Description').text = quest.description
    for (var valueName in quest.values) {
      var goalPanel = CreateLayout($('#Goals'), valueName, 'file://{resources}/layout/custom_game/quest/goal.xml')
      goalPanel.LoadGoal(valueName, quest.values[valueName], quest.valueGoals[valueName])
      goalPanels[valueName] = goalPanel
    }
  }
  $.GetContextPanel().SetValue = function (valueName, value) {
    goalPanels[valueName].SetValue(value)
  }
  $.GetContextPanel().Complete = function () {
    $('#Name').AddClass('Completed')
    $('#Description').AddClass('Completed')
  }
  $.GetContextPanel().Fail = function () {
    $('#Name').AddClass('Failed')
    $('#Description').AddClass('Failed')
  }
  $.GetContextPanel().Destroy = function () {
    $.GetContextPanel().AddClass('SlideOut')
    $.GetContextPanel().DeleteAsync(2)
  }
}())
