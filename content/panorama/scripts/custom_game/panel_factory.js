function CreateLayout (parent, id, layout) {
  var panel = $.CreatePanel('Panel', parent, id)
  panel.BLoadLayout(layout, false, false)
  return panel
}

function LinkLabelToPlayerVariable (label, varName) {
  var localPly = Players.GetLocalPlayer()
  label.text = Players['Get' + varName](localPly)
  if (varName === 'Gold') {
    var UpdateGold = function () {
      $.Schedule(0.5, UpdateGold)
      label.text = Players.GetGold(localPly)
    }
    UpdateGold()
  } else {
    GameEvents.Subscribe('player_networkvar_update', function (data) {
      if (data.PlayerID === Players.GetLocalPlayer() && varName === data.varname) {
        label.text = data.value
      }
    })
  }
}
