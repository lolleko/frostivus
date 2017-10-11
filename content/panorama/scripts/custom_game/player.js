Players.PlayerData = {}

function OnPlayerNetworkVarUpdate (e) {
  var playerID = e.PlayerID
  var name = e.varname
  if (!Players.PlayerData[playerID]) {
    Players.PlayerData[playerID] = {}
  }
    // [PanoramaScript] !! (s2r://panorama/scripts/custom_game/player.vjs_c, line:12, col:40) - TypeError: Cannot read property 'NemesisScore' of undefined
  Players.PlayerData[playerID][name] = e.value
  if (!Players['Get' + name]) {
    Players['Get' + name] = function (plyID) {
      plyID = (typeof plyID !== 'undefined') ? plyID : Players.GetLocalPlayer()
      if (typeof plyID === 'undefined') {
        if (!Players.PlayerData[plyID]) {
          return
        }
      }
      return Players.PlayerData[plyID][name]
    }
  }
}

GameEvents.Subscribe('player_networkvar_update', OnPlayerNetworkVarUpdate)
