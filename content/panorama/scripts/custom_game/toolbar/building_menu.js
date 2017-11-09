(function () {
  $.GetContextPanel().LoadCategory = function (categoryName) {
    var category = $.CreatePanel('Panel', $.GetContextPanel(), categoryName)
    category.AddClass('Category')
    var columnLabel = $.CreatePanel('Label', category, categoryName + '_label')
    category.AddClass('CategoryLabel')
    columnLabel.text = categoryName
    var categoryRow = $.CreatePanel('Panel', $.GetContextPanel(), categoryName + '_row')
    categoryRow.AddClass('CategoryRow')

    var buildings = Players.GetBuildingShopKV(Players.GetLocalPlayer())
    var sortedBuildings = []
    for (var buildingName in buildings) {
      var building = buildings[buildingName]
      if (building.Category === categoryName) {
        building.BuildingNameJS = buildingName
        sortedBuildings.push(building)
      }
    }
    sortedBuildings.sort(function (a, b) {
      return a.BuildingID - b.BuildingID
    })
    sortedBuildings.forEach(function (building) {
      var buildingEntry = CreateLayout(categoryRow, building.BuildingNameJS, 'file://{resources}/layout/custom_game/toolbar/entry.xml')
      buildingEntry.LoadBuilding(building.BuildingNameJS, building)
    })
  }
}())
