function CreateLayout(parent, id, layout) {
  var panel = $.CreatePanel('Panel', parent, id)
  panel.BLoadLayout(layout, false, false)
  return panel
}
