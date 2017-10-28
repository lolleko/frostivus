(function () {
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ELEMENT_COUNT, false)

  var toolbar = CreateLayout($.GetContextPanel(), 'ToolbarRight', 'file://{resources}/layout/custom_game/buy_menu/toolbar_side.xml')
  var buildings = CreateLayout($.GetContextPanel(), 'BuildingMenu', 'file://{resources}/layout/custom_game/buy_menu/content.xml')
  buildings.LoadCategory('Buildings')
  toolbar.Insert('Buildings', buildings)

  LinkLabelToPlayerVariable($('#LumberCurrent'), 'Lumber')
  LinkLabelToPlayerVariable($('#LumberCapacity'), 'LumberCapacity')

  LinkLabelToPlayerVariable($('#GoldCurrent'), 'Gold')
  LinkLabelToPlayerVariable($('#GoldCapacity'), 'GoldCapacity')
}())
