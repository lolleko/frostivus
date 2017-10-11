(function () {
  $.GetContextPanel().LoadInvestment = function(investmentName, investment) {
    $('#Name').text = investmentName
    $('#ButtonWrap').SetPanelEvent(
      "onactivate",
      function(){
        GameEvents.SendCustomGameEventToServer('investmentRequest', {'investmentName': investmentName})
      })
  }
}())
