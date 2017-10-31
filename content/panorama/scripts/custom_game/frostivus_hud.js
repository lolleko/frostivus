(function () {
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false)
  // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ELEMENT_COUNT, false)

  var toolbar = CreateLayout($.GetContextPanel(), 'ToolbarRight', 'file://{resources}/layout/custom_game/toolbar/toolbar_side.xml')
  var buildings = CreateLayout($.GetContextPanel(), 'BuildingMenu', 'file://{resources}/layout/custom_game/toolbar/building_menu.xml')
  buildings.LoadCategory('Defense')
  buildings.LoadCategory('Resources')
  toolbar.Insert('Buildings', buildings)

  var shopBtn = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse('ShopButton')
  shopBtn.style.width = '240px'
  shopBtn.style.flowChildren = 'right'
  shopBtn.RemoveAndDeleteChildren()

  function resourcePanel (parent, name, iconPath) {
    var container = $.CreatePanel('Panel', parent, name + '_' + 'container')
    container.style.flowChildren = 'right'
    container.style.marginLeft = '2px'
    container.style.verticalAlign = 'center'

    var icon = $.CreatePanel('Panel', container, name + '_' + 'icon')
    icon.style.backgroundImage = iconPath
    icon.style.backgroundSize = '100% 100%'
    icon.style.verticalAlign = 'center'
    icon.style.width = '26px'
    icon.style.height = '26px'
    icon.style.marginRight = '4px'
    var lblCurrent = $.CreatePanel('Label', container, name + '_' + 'current')
    lblCurrent.style.fontSize = '22px'
    var lblSlash = $.CreatePanel('Label', container, name + '_' + 'slash')
    lblSlash.text = '/'
    lblSlash.style.fontSize = '22px'
    var lblCap = $.CreatePanel('Label', container, name + '_' + 'cap')
    lblCap.style.fontSize = '22px'

    LinkLabelToPlayerVariable(lblCurrent, name, true)
    LinkLabelToPlayerVariable(lblCap, name + 'Capacity', true)
    return container
  }

  resourcePanel(shopBtn, 'Lumber', 'url("file://{images}/custom_game/icons/lumber_icon.psd")')
  resourcePanel(shopBtn, 'Gold', 'url("s2r://panorama/images/hud/reborn/gold_small_psd.vtex")')
}())
