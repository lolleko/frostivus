(function () {
  $.GetContextPanel().LoadCategory = function (categoryName) {
    var category = $.CreatePanel('Panel', $.GetContextPanel(), categoryName)
    category.AddClass('Category')
    var columnLabel = $.CreatePanel('Label', category, categoryName + '_label')
    category.AddClass('Label')
    columnLabel.text = categoryName
    var categoryRow = $.CreatePanel('Panel', $.GetContextPanel(), categoryName + '_row')
    categoryRow.AddClass('CategoryRow')

    var buildings = Players.GetBuildingShopKV(Players.GetLocalPlayer())
    for (var buildingName in buildings) {
      var building = buildings[buildingName]
      if (building.Category === categoryName) {
        var buildingEntry = CreateLayout(categoryRow, buildingName, 'file://{resources}/layout/custom_game/toolbar/entry.xml')
        buildingEntry.LoadBuilding(buildingName, building)
      }
    }
  }
}())
