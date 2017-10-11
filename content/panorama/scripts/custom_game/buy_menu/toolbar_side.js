(function () {
  $.GetContextPanel().Insert = function (name, content) {
    // TODO replace with custom IconButton type
    var toolbarButton = $.CreatePanel('Button', $('#ToolbarControls'), name + 'Button')
    toolbarButton.AddClass('ToolbarButton')

    toolbarButton.SetPanelEvent(
      "onactivate",
      function(){
        var hide = content.BHasClass('visible')
        $('#ToolbarContent').Children().forEach(function(item){
          item.RemoveClass('visible')
        })
        if (hide) {
          content.RemoveClass('visible')
        } else {
          content.AddClass('visible')
        }
      })
    content.SetParent($('#ToolbarContent'))
    content.AddClass('ToolbarContentEntry')
    return content
  }
}())
