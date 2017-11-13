(function () {
  var valueGoal
  $.GetContextPanel().LoadGoal = function (name, value, goal) {
    $('#Name').text = $.Localize('#' + name)
    valueGoal = goal
    if (goal === 1) {
      $('#Value').text = ''
      $('#Goal').text = ''
      $('#Slash').text = ''
    } else {
      $('#Value').text = value
      $('#Goal').text = goal
    }
  }
  $.GetContextPanel().SetValue = function (value) {
    if (valueGoal !== 1) {
      $('#Value').text = value
    }
    if (value === valueGoal) {
      $('#CheckBox').AddClass('CheckBoxFilled')
      $.GetContextPanel().AddClass('GoalRootCompleted')
    }
  }
}())
