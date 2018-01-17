(function () {
  $.GetContextPanel().Insert = function (name, content) {
    // TODO replace with custom IconButton type
    var toolbarButton = $.CreatePanel('Button', $('#ToolbarControls'), name + 'Button')
    toolbarButton.AddClass('ToolbarButton')

    toolbarButton.SetPanelEvent(
      'onactivate',
      function () {
        toolbarButton.RemoveClass('Highlight')
        var hide = content.BHasClass('visible')
        $('#ToolbarContent').Children().forEach(function (item) {
          item.RemoveClass('visible')
        })
        if (hide) {
          content.RemoveClass('visible')
        } else {
          content.AddClass('visible')
        }
        $.DispatchEvent('DOTAShopHideShop')
      })

    var shopButton = $.GetContextPanel()
    .GetParent()
    .GetParent() // HUD root
    .GetParent() // Custom UI root
    .GetParent() // Game HUD
    .FindChildTraverse('ShopButton')
    $.Msg(shopButton)

    $.RegisterEventHandler('DOTAHUDToggleShop', shopButton, function () {
      content.RemoveClass('visible')
    })
    content.SetParent($('#ToolbarContent'))
    content.AddClass('ToolbarContentEntry')
    return content
  }
}())
