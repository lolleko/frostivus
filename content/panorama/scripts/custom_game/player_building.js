(function () {
  var previewParticle
  var previewActive = false
  var rangeParticle
  var arrowParticle
  var range = 0
  var sizeX
  var sizeY
  var center
  var squareParticles = []
  var blockedSquaresParticles = []
  var buildingName
  var worldPos
  var blocked = false
  var rotation = 360
  function OnStartPreview (data) {
    if (previewParticle || previewActive) {
      StopPreview()
    }
    previewActive = true
    var entindex = data.previewModel
    sizeX = data.sizeX
    sizeY = data.sizeY
    buildingName = data.buildingName
    previewParticle = Particles.CreateParticle('particles/misc/building_preview.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
    Particles.SetParticleControlEnt(previewParticle, 1, entindex, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, 'follow_origin', Entities.GetAbsOrigin(entindex), true)
    Particles.SetParticleControl(previewParticle, 2, [150, 255, 150])
    Particles.SetParticleControl(previewParticle, 3, [data.scale, 0, 0])

    if (data.drawArrow) {
      arrowParticle = Particles.CreateParticle('particles/misc/building_arrow.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
      Particles.SetParticleControlEnt(arrowParticle, 1, entindex, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, 'follow_origin', Entities.GetAbsOrigin(entindex), true)
      Particles.SetParticleControl(arrowParticle, 2, [150, 255, 150])
      Particles.SetParticleControl(arrowParticle, 3, [5, 0, 0])
    }

    rangeParticle = Particles.CreateParticle('particles/misc/building_range_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
    Particles.SetParticleControl(rangeParticle, 0, data.center)
    Particles.SetParticleControl(rangeParticle, 1, [data.range, 0, 0])
    range = data.range
    center = data.center
    // Particles.SetParticleControl(rangeParticle, 1, [data.range, 0, 0]) // hardcoded in aprticle
    // cahce squareParticles
    var squareParticle
    for (var i = 0; i < sizeX * sizeY; i++) {
      squareParticle = Particles.CreateParticle('particles/misc/building_grid_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
      Particles.SetParticleControl(squareParticle, 1, [150, 255, 150])

      squareParticles.push(squareParticle)
    }

    UpdateBlockedSquares(data)
    UpdatePreview()
    $.GetContextPanel().GetParent().FindChildTraverse('BuildTutorial').style.visibility = 'visible'
  }
  GameEvents.Subscribe('buildingStartPreview', OnStartPreview)

  function UpdateBlockedSquares () {
    if (previewActive) {
      // dont do this that often as it will eb laggy
      $.Schedule(1, UpdateBlockedSquares)
      GameEvents.SendCustomGameEventToServer('buildingCheckBlockedSquares', {'center': center, 'range': range})
    }
  }

  function DrawBlockedSquares (data) {
    var deleteLater = blockedSquaresParticles.slice(0)
    blockedSquaresParticles = []
    if (previewActive) {
      var topLeft = data.blockedSquares.topLeft.split(' ').map(Number)
      var lines = data.blockedSquares.lines
      var charCount = lines.length
      var padding = data.blockedSquares.padding
      var lineArr = []
      var index = 0
      // unpack
      lineArr[0] = ''
      for (var i = 0; i < charCount; i++) {
        if (lines[i] === ';') {
          lineArr[index] = lineArr[index].substring(0, lineArr[index].length - padding)
          index++
          lineArr[index] = ''
        } else {
          var binPad = parseInt(lines[i], 16).toString(2)
          lineArr[index] += Array(4 + 1 - binPad.length).join('0') + binPad
        }
      }
      var initialX = topLeft[0]
      for (i = 0; i < lineArr.length; i++) {
        for (var j = 0; j < lineArr[i].length; j++) {
          if (lineArr[i][j] === '1') {
            var squareParticle = Particles.CreateParticle('particles/misc/building_grid_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
            Particles.SetParticleControl(squareParticle, 0, topLeft)
            Particles.SetParticleControl(squareParticle, 1, [255, 150, 150])
            blockedSquaresParticles.push(squareParticle)
          }
          topLeft[0] += 64
        }
        topLeft[0] = initialX
        topLeft[1] -= 64
      }
      $.Schedule(0.1, function () {
        deleteLater.forEach(function (square) {
          Particles.DestroyParticleEffect(square, true)
          Particles.ReleaseParticleIndex(square)
        })
      })
      // for (var index in data.lines) {
      //   var squarePos = data.blockedSquares[index]
      //   var squareParticle = Particles.CreateParticle('particles/misc/building_grid_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
      //   Particles.SetParticleControl(squareParticle, 0, squarePos)
      //   Particles.SetParticleControl(squareParticle, 1, [255, 150, 150])
      //   blockedSquaresParticles.push(squareParticle)
      // }
    }
  }
  GameEvents.Subscribe('buildingUpdateBlockedSquares', DrawBlockedSquares)

  function StopPreview () {
    previewActive = false
    blocked = false
    Particles.DestroyParticleEffect(previewParticle, true)
    Particles.ReleaseParticleIndex(previewParticle)
    previewParticle = null

    if (arrowParticle) {
      Particles.DestroyParticleEffect(arrowParticle, true)
      Particles.ReleaseParticleIndex(arrowParticle)
      arrowParticle = null
    }

    Particles.DestroyParticleEffect(rangeParticle, true)
    Particles.ReleaseParticleIndex(rangeParticle)
    rangeParticle = null

    range = 0
    rotation = 360
    squareParticles.forEach(function (square) {
      Particles.DestroyParticleEffect(square, true)
      Particles.ReleaseParticleIndex(square)
    })
    squareParticles = []
    blockedSquaresParticles.forEach(function (square) {
      Particles.DestroyParticleEffect(square, true)
      Particles.ReleaseParticleIndex(square)
    })
    blockedSquaresParticles = []
    $.GetContextPanel().GetParent().FindChildTraverse('BuildTutorial').style.visibility = 'collapse'
  }

  function RotatePreview () {
    rotation = rotation - 90
    if (rotation === 0) {
      rotation = 360
    }
    var tempSize = sizeX
    sizeX = sizeY
    sizeY = tempSize
  }

  function UpdatePreview () {
    if (previewActive) {
      $.Schedule(1 / 20, UpdatePreview)
    } else {
      return
    }

    var cursorPos = GameUI.GetCursorPosition()
    worldPos = Game.ScreenXYToWorld(cursorPos[0], cursorPos[1])
    if (worldPos !== null) {
      worldPos = [64 * Math.floor(0.5 + worldPos[0] / 64), 64 * Math.floor(0.5 + worldPos[1] / 64), worldPos[2] - ((worldPos[2] + 1) % 128)]
      if (worldPos[0] > 10000000 || worldPos[1] > 10000000 || worldPos[2] > 10000000) return
      var gridPointer = [worldPos[0] - (sizeX / 2) * 64, worldPos[1] + (sizeY / 2) * 64, worldPos[2] + 1]
      var initialY = gridPointer[1]
      var particleID = 0
      for (var x = 0; x < sizeX; x++) {
        gridPointer[1] = initialY
        gridPointer[0] = gridPointer[0] + 32
        for (var y = 0; y < sizeY; y++) {
          gridPointer[1] = gridPointer[1] - 32
          Particles.SetParticleControl(squareParticles[particleID], 0, gridPointer)
            // resource intensive and doest really look good on high ping
            // GameEvents.SendCustomGameEventToServer('buildingCheckSquare', { 'origin': gridPointer, 'squareID': particleID })
          gridPointer[1] = gridPointer[1] - 32
          particleID++
        }
        gridPointer[0] = gridPointer[0] + 32
      }
      GameEvents.SendCustomGameEventToServer('buildingCheckArea', {'origin': worldPos, 'sizeX': sizeX, 'sizeY': sizeY, 'rotation': rotation, 'range': range})
        // GameEvents.SendCustomGameEventToServer('structure_preview_update', { 'pos': worldPos })
      Particles.SetParticleControl(previewParticle, 0, worldPos)
      if (arrowParticle) {
        worldPos[2] += 350 + Math.sin(Game.GetGameTime() * 2) * 10
        Particles.SetParticleControl(arrowParticle, 0, worldPos)
      }
    }
  }

  function OnUpdateSquareBlocked (data) {
    if (data.blocked === 1) {
      Particles.SetParticleControl(squareParticles[data.squareID], 1, [255, 150, 150])
    } else {
      Particles.SetParticleControl(squareParticles[data.squareID], 1, [150, 255, 150])
    }
  }
  GameEvents.Subscribe('buildingUpdateSquare', OnUpdateSquareBlocked)

  function OnUpdatePreviewBlocked (data) {
    if (!previewActive) {
      return
    }
    if (data.blocked === 1) {
      squareParticles.forEach(function (square) {
        Particles.SetParticleControl(square, 1, [255, 150, 150])
      })
      Particles.SetParticleControl(previewParticle, 2, [255, 150, 150])
      if (arrowParticle) {
        Particles.SetParticleControl(arrowParticle, 2, [255, 150, 150])
      }

      blocked = true
    } else {
      squareParticles.forEach(function (square) {
        Particles.SetParticleControl(square, 1, [150, 255, 150])
      })
      Particles.SetParticleControl(previewParticle, 2, [150, 255, 150])
      if (arrowParticle) {
        Particles.SetParticleControl(arrowParticle, 2, [150, 255, 150])
      }

      blocked = false
    }
  }
  GameEvents.Subscribe('buildingUpdatePreview', OnUpdatePreviewBlocked)

  GameUI.SetMouseCallback(function (eventName, arg) {
    if (GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE || !previewActive) {
      return false
    }
    if (eventName === 'pressed') {
      // Left-click is try build
      if (arg === 0) {
        if (blocked) {
          Players.SendCastError('frostivus_hud_error_space_blocked')
        } else {
          var queue = GameUI.IsShiftDown()
          GameEvents.SendCustomGameEventToServer('buildingRequestConstruction', {'origin': worldPos, 'buildingName': buildingName, 'queue': queue, 'rotation': rotation})
          if (!queue) {
            StopPreview()
          }
        }
        return true
      }
      // right-click is cancel
      if (arg === 1) {
        StopPreview()
        GameEvents.SendCustomGameEventToServer('buildingRequestConstruction', { 'cancel': true })
        return true
      }
      // middle mouse is rotate
      if (arg === 2) {
        RotatePreview()
      }
    }
    return false
  })
}())
