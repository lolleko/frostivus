(function () {
  $.GetContextPanel().LoadCategory = function (categoryName) {
    var abilityColumn = $.CreatePanel('Panel', $.GetContextPanel(), categoryName + '_column')
    abilityColumn.AddClass('AbilityColumn')
    var columnLabel = $.CreatePanel('Label', abilityColumn, categoryName + '_label')
    columnLabel.text = categoryName

    var investments = Players.GetInvestmentsKV(Players.GetLocalPlayer())
    for (var investmentName in investments) {
      var investment = investments[investmentName]
      if (investment.Category == categoryName) {
        var investmentEntry = CreateLayout(abilityColumn, investmentName, "file://{resources}/layout/custom_game/buy_menu/entry.xml")
        investmentEntry.LoadInvestment(investmentName, investment)
      }
    }

    var childCount = $.GetContextPanel().GetChildCount()
    var percentage = 100 / childCount
    $.GetContextPanel().Children().forEach(function(item){
      item.style.width = percentage + '%'
    })
  }
}())
