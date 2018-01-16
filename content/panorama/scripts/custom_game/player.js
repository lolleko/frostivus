function createGetter (varName) {
  return function (plyID) {
    plyID = (typeof plyID !== 'undefined') ? plyID : Players.GetLocalPlayer()
    return CustomNetTables.GetTableValue('player_data', plyID + varName).value
  }
}

CustomNetTables.GetAllTableValues('player_data').forEach(function (item) {
  Players['Get' + item.key.replace(/[0-9]+/, '')] = createGetter(item.key.replace(/[0-9]+/, ''))
})

Players.RegisterNetworkVarListener = function (name, callback, plyID) {
  plyID = (typeof plyID !== 'undefined') ? plyID : Players.GetLocalPlayer()
  CustomNetTables.SubscribeNetTableListener('player_data', function (tableName, key, data) {
    if (key === plyID + name) {
      callback(data.value)
    }
  })
}

Players.SendCastError = function (message, reason) {
  var eventData
  if (typeof message === 'object') {
    eventData = message
  } else {
    eventData = { reason: reason, message: message }
  }
  if (!eventData.reason) {
    eventData.reason = 80
  }
  GameEvents.SendEventClientSide('dota_hud_error_message', eventData)
}

GameEvents.Subscribe('cg_custom_cast_error', function (e) {
  Players.SendCastError(e)
})

GameEvents.Subscribe('cg_ping_minimap', function (e) {
  GameUI.PingMinimapAtLocation(e.pos)
})
