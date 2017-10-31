(function () {
  $.GetContextPanel().LoadBuilding = function (buildingName, buildingData) {
    $('#Name').text = buildingName
    if (buildingData.Requirements) {
      $('#LumberCost').text = buildingData.Requirements.LumberCost ? nFormatter(buildingData.Requirements.LumberCost) : ''
      $('#GoldCost').text = buildingData.Requirements.GoldCost ? nFormatter(buildingData.Requirements.GoldCost) : ''
    } else {
      $('#LumberCost').text = ''
      $('#GoldCost').text = ''
    }
    var btn = $('#ButtonWrap')
    btn.SetPanelEvent(
      'onactivate',
      function () {
        GameEvents.SendCustomGameEventToServer('buildingPreviewRequest', {'unitName': buildingName})
      })
    btn.SetPanelEvent(
        'onmouseover',
        function () {
          $.DispatchEvent('DOTAShowTitleTextTooltip', btn, buildingName, 'Description')
        })

    btn.SetPanelEvent(
            'onmouseout',
            function () {
              $.DispatchEvent('DOTAHideTitleTextTooltip', btn)
            })
  }
}())
