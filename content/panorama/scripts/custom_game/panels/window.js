(function () {

  $('#TitleBarDrag').SetPanelEvent(
    "onmouseactivate",
    function(){
      var cursorPos = GameUI.GetCursorPosition()
      var windowPos = $.GetContextPanel().GetPositionWithinWindow()
      $.GetContextPanel().dragOffset = [cursorPos[0] - windowPos.x, cursorPos[1] - windowPos.y]
      $.GetContextPanel().lastCursorPos = GameUI.GetCursorPosition()
      $.Schedule(1/30, dragWindowThink)
  })

  $('#TitleBarClose').SetPanelEvent(
    "onmouseactivate",
    function(){
      $.GetContextPanel().Toggle()
  })

  $.GetContextPanel().SetTitle = function (title) {
    $('#TitleBarLabel').text = title
  }

  $.GetContextPanel().Toggle = function () {
    if ($.GetContextPanel().style.visibility == 'collapse') {
      $.GetContextPanel().style.visibility = 'visible';
    } else {
      $.GetContextPanel().style.visibility = 'collapse';
    }
  }

  $.GetContextPanel().SetContent = function (panel) {
    panel.SetParent($('#Content'))
    return panel
  }

  function dragWindowThink() {
    var lastCursorPos = $.GetContextPanel().lastCursorPos
    var currentCursorPos = GameUI.GetCursorPosition()
    var dragOffset = $.GetContextPanel().dragOffset
    if (!GameUI.IsMouseDown(0)) {
      if (lastCursorPos[0] !== currentCursorPos[0] || lastCursorPos[1] !== currentCursorPos[1]) {
        var currentWindowPos = $.GetContextPanel().GetPositionWithinWindow()
        var newX = currentCursorPos[0] / $.GetContextPanel().actualuiscale_x
        var newY = currentCursorPos[1] / $.GetContextPanel().actualuiscale_x
        $.GetContextPanel().style.marginLeft = newX + "px"
        $.GetContextPanel().style.marginTop = newY + "px"
      }
      $.GetContextPanel().lastCursorPos = GameUI.GetCursorPosition()
      $.Schedule(1/30, dragWindowThink)
    }
  }

  /*
  GameUI.SetMouseCallback(function(eventName, btn) {
    if (eventName === 'pressed' && btn === 0) {
      var windowPos = $.GetContextPanel().GetPositionWithinWindow()
      var boundX = windowPos.x + $('#TitleBar').desiredlayoutwidth
      var boundY = windowPos.y + $('#TitleBar').desiredlayoutheight
      var cursorPos = GameUI.GetCursorPosition()
      $.Msg($.GetContextPanel().GetPositionWithinWindow(), GameUI.GetCursorPosition(), boundX, boundY)
      if (cursorPos[0] >= windowPos.x && cursorPos[0] <= boundX && cursorPos[1] >= windowPos.y && cursorPos[1] <= boundY) {
        $.Msg("clicked title")
      }
    }
  });*/
}())
