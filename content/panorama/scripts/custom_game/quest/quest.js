(function () {
  var goalPanels = {}
  var timeLeft
  var timeLimit
  $.GetContextPanel().LoadQuest = function (quest) {
    $('#Name').text = $.Localize('#' + quest.name)
    $('#Description').text = $.Localize('#' + quest.name + '_Description')
    if ($('#Description').text === '') {
      $('#Description').style.visibility = 'collapse'
    }
    for (var valueName in quest.values) {
      var goalPanel = CreateLayout($('#Goals'), valueName, 'file://{resources}/layout/custom_game/quest/goal.xml')
      goalPanel.LoadGoal(valueName, quest.values[valueName], quest.valueGoals[valueName])
      goalPanels[valueName] = goalPanel
    }
    if (quest.timeLimit) {
      $.Schedule(1, timer)
      timeLeft = quest.timeLimit
      timeLimit = quest.timeLimit
      $('#Timer').style.visibility = 'visible'
      $('#TimerLabel').text = timeLeft
    }
  }
  function timer () {
    if (timeLeft !== 0) {
      $.Schedule(1, timer)
    }
    if (!Game.IsGamePaused()) {
      timeLeft--
    }
    $('#TimerLabel').text = util.secondsToString(timeLeft)
    $('#TimerProgressBarInner').style.width = (timeLeft / timeLimit * 100) + '%'
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
