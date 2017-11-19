(function () {
  // Turn off some default UI
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, true)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, true)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_QUICK_STATS, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_PREGAME_STRATEGYUI, false)
  GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_KILLCAM, false)

  var toolbar = CreateLayout($.GetContextPanel(), 'ToolbarRight', 'file://{resources}/layout/custom_game/toolbar/toolbar_side.xml')
  var buildings = CreateLayout($.GetContextPanel(), 'BuildingMenu', 'file://{resources}/layout/custom_game/toolbar/building_menu.xml')
  buildings.LoadCategory('Defense')
  buildings.LoadCategory('Resources')
  buildings.LoadCategory('Units')
  toolbar.Insert('Buildings', buildings)

  $.Msg(Players.GetBuildingShopKV(Players.GetLocalPlayer()))

  var shopBtn = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse('ShopButton')
  shopBtn.style.width = '240px'
  shopBtn.style.flowChildren = 'right'
  shopBtn.RemoveAndDeleteChildren()

  function resourcePanel (parent, name, iconPath, alignRight) {
    var container = $.CreatePanel('Panel', parent, name + '_' + 'container')
    container.style.flowChildren = 'right'
    container.style.verticalAlign = 'center'
    if (alignRight) {
      container.style.horizontalAlign = 'right'
      container.style.marginRight = '2px'
    } else {
      container.style.marginLeft = '2px'
    }

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

    util.linkLabelToPlayerVariable(lblCurrent, name, true)
    util.linkLabelToPlayerVariable(lblCap, name + 'Capacity', true)
    return container
  }

  resourcePanel(shopBtn, 'Lumber', 'url("file://{images}/custom_game/icons/lumber_icon.psd")')
  resourcePanel(shopBtn, 'Gold', 'url("s2r://panorama/images/hud/reborn/gold_small_psd.vtex")', true)

  function activeUnitChanged () {
    var portraitUnit = Players.GetLocalPlayerPortraitUnit(Players.GetLocalPlayer())
    var upgrade = Entities.GetAbilityByName(portraitUnit, 'frostivus_building_upgrade')
    if (upgrade !== -1) {
      $('#StatBranch').style.visibility = 'collapse'
      var upgradeInfo = $('#UpgradeInfo')
      upgradeInfo.style.visibility = 'visible'
      upgradeInfo.RemoveAndDeleteChildren()
      var unitName = Entities.GetUnitName(portraitUnit)
      var upgradeName = unitName.slice(0, -1) + (Entities.GetLevel(portraitUnit) + 1)
      var tooltipContainer = $.CreatePanel('Panel', upgradeInfo, upgradeName)
      tooltipContainer.style.tooltipPosition = 'top right'
      tooltipContainer.style.width = '100%'
      tooltipContainer.style.height = '100%'
      upgradeInfo.ClearPanelEvent('onmouseover')
      upgradeInfo.ClearPanelEvent('onmouseout')
      upgradeInfo.SetPanelEvent(
        'onmouseover',
        function () {
          $.DispatchEvent('UIShowCustomLayoutParametersTooltip', tooltipContainer, tooltipContainer.id, 'file://{resources}/layout/custom_game/building_tooltip.xml', 'buildingName=' + upgradeName + '&compareWithPrevTier=true')
        })
      upgradeInfo.SetPanelEvent(
        'onmouseout',
        function () {
          $.DispatchEvent('UIHideCustomLayoutTooltip', tooltipContainer, tooltipContainer.id)
        })
    } else {
      $('#StatBranch').style.visibility = 'visible'
      $('#UpgradeInfo').style.visibility = 'collapse'
    }
  }
  GameEvents.Subscribe('dota_player_update_query_unit', activeUnitChanged)
  GameEvents.Subscribe('dota_player_update_selected_unit', activeUnitChanged)
}())
