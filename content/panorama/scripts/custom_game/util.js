function util () {

}

util.secondsToString = function (seconds) {
  var minutes = Math.floor(seconds / 60)
  seconds = Math.floor(seconds - (minutes * 60))
  return minutes + ':' + util.pad(seconds, 2)
}

util.pad = function (num, size) { return ('000000000' + num).substr(-size) }

util.linkLabelToPlayerVariable = function (label, varName, prettyNumber) {
  var localPly = Players.GetLocalPlayer()
  var text = Players['Get' + varName](localPly)
  if (prettyNumber) {
    text = util.nFormatter(text)
  }
  label.text = text
  if (varName === 'Gold') {
    var UpdateGold = function () {
      $.Schedule(0.5, UpdateGold)
      var text = Players.GetGold(localPly)
      if (prettyNumber) {
        text = util.nFormatter(text)
      }
      label.text = text
    }
    UpdateGold()
  } else {
    GameEvents.Subscribe('player_networkvar_update', function (data) {
      if (data.PlayerID === Players.GetLocalPlayer() && varName === data.varname) {
        var text = data.value
        if (prettyNumber) {
          text = util.nFormatter(text)
        }
        label.text = text
      }
    })
  }
}

var SI_PREFIXES = ['', 'k', 'M', 'G', 'T', 'P', 'E']
util.nFormatter = function (number) {
  var tier = Math.log10(number) / 3 | 0

  if (tier === 0) return number

  var prefix = SI_PREFIXES[tier]

  var scale = Math.pow(10, tier * 3)

  var scaled = number / scale

  return scaled.toFixed(1) + prefix
}
