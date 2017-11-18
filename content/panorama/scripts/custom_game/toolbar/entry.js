(function () {
  $.GetContextPanel().LoadBuilding = function (buildingName, buildingData) {
    $('#Name').text = $.Localize('#' + buildingName)
    $('#BuildingImage').style.backgroundImage = 'url("file://{images}/custom_game/buildings/' + buildingName + '.psd")'
    if (buildingData.Requirements) {
      if (buildingData.Requirements.LumberCost) {
        $('#LumberCost').text = util.nFormatter(buildingData.Requirements.LumberCost)
      } else {
        $('#LumberPanel').style.visibility = 'collapse'
      }
      if (buildingData.Requirements.GoldCost) {
        $('#GoldCost').text = util.nFormatter(buildingData.Requirements.GoldCost)
      } else {
        $('#GoldPanel').style.visibility = 'collapse'
      }
    } else {
      $('#LumberCost').text = ''
      $('#GoldCost').text = ''
    }
    var btn = $('#ButtonWrap')
    if (buildingData.Requirements.Stage > Players.GetGameStage()) {
      btn.AddClass('Locked')
    }
    btn.SetPanelEvent(
      'onactivate',
      function () {
        GameEvents.SendCustomGameEventToServer('buildingPreviewRequest', {
          'unitName': buildingName
        })
      })
    btn.SetPanelEvent(
      'onmouseover',
      function () {
        $.DispatchEvent('UIShowCustomLayoutParametersTooltip', $.GetContextPanel(), $.GetContextPanel().id, 'file://{resources}/layout/custom_game/building_tooltip.xml', 'buildingName=' + buildingName)
      })

    btn.SetPanelEvent(
      'onmouseout',
      function () {
        $.DispatchEvent('UIHideCustomLayoutTooltip', $.GetContextPanel(), $.GetContextPanel().id)
      })
    Players.RegisterNetworkVarListener('GameStage', function (value) {
      if (buildingData.Requirements.Stage === value) {
        $('#ButtonWrap').RemoveClass('Locked')
      }
    })
  }
}())
