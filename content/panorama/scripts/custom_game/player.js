Players.PlayerData = {}
Players.NetworkVarCallbacks = {}
Players.NetworkInitCallbacks = []
Players.NetworkInitialized = false

function OnPlayerNetworkVarUpdate (e) {
  var playerID = e.PlayerID
  var name = e.varname

  Players.PlayerData[playerID][name] = e.value

  if (Players.NetworkVarCallbacks[name]) {
    Players.NetworkVarCallbacks[name].forEach(function (callback) {
      callback(e.value)
    })
  }
}
GameEvents.Subscribe('player_networkvar_update', OnPlayerNetworkVarUpdate)

function OnPlayerNetworkVarInit (e) {
  // get table for lcoal player and create accessors
  Players.PlayerData = e
  var localPlayerData = e[Players.GetLocalPlayer()]

  function createGetter (varName) {
    return function (plyID) {
      plyID = (typeof plyID !== 'undefined') ? plyID : Players.GetLocalPlayer()
      return Players.PlayerData[plyID][varName]
    }
  }

  for (var name in localPlayerData) {
    Players['Get' + name] = createGetter(name)
  }
  Players.NetworkInitialized = true
  Players.NetworkInitCallbacks.forEach(function (callback) {
    callback()
  })
}
GameEvents.Subscribe('player_networkvar_init', OnPlayerNetworkVarInit)

function OnPlayerNetworkVarNewPlayer (e) {
  // ignore if this is our own data
  if (e.PlayerID !== Players.GetLocalPlayer()) {
    Players.PlayerData[e.PlayerID] = e.data
  }
}
GameEvents.Subscribe('player_networkvar_new_player', OnPlayerNetworkVarNewPlayer)

Players.RegisterNetworkVarListener = function (name, callback) {
  if (!Players.NetworkVarCallbacks[name]) {
    Players.NetworkVarCallbacks[name] = []
  }
  Players.NetworkVarCallbacks[name].push(callback)
}

Players.RegisterNetworkInitListener = function (callback) {
  // if we are readdy immediatly invoke function
  // if not register callback
  if (Players.NetworkInitialized) {
    callback()
  } else {
    Players.NetworkInitCallbacks.push(callback)
  }
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
