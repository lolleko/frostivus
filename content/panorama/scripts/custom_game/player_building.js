(function () {
  var previewParticle
  var previewActive = false
  var rangeParticle
  var range = 0
  var sizeX
  var sizeY
  var squareParticles = []
  var blockedSquaresParticles = []
  var investmentName
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
    investmentName = data.investmentName
    previewParticle = Particles.CreateParticle('particles/misc/building_preview.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
    Particles.SetParticleControlEnt(previewParticle, 1, entindex, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, 'follow_origin', Entities.GetAbsOrigin(entindex), true)
    Particles.SetParticleControl(previewParticle, 2, [150, 255, 150])
    Particles.SetParticleControl(previewParticle, 3, [data.scale, 0, 0])

    rangeParticle = Particles.CreateParticle('particles/misc/building_range_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
    Particles.SetParticleControl(rangeParticle, 0, data.center)
    Particles.SetParticleControl(rangeParticle, 1, [data.range, 0, 0])
    range = data.range
    // Particles.SetParticleControl(rangeParticle, 1, [data.range, 0, 0]) // hardcoded in aprticle
    // cahce squareParticles
    var squareParticle
    for (var i = 0; i < sizeX * sizeY; i++) {
      squareParticle = Particles.CreateParticle('particles/misc/building_grid_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
      Particles.SetParticleControl(squareParticle, 1, [150, 255, 150])

      squareParticles.push(squareParticle)
    }
    for (var index in data.blockedSquares) {
      var squarePos = data.blockedSquares[index]
      squareParticle = Particles.CreateParticle('particles/misc/building_grid_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0)
      Particles.SetParticleControl(squareParticle, 0, squarePos)
      Particles.SetParticleControl(squareParticle, 1, [255, 150, 150])
      blockedSquaresParticles.push(squareParticle)
    }

    UpdatePreview()
    $.GetContextPanel().GetParent().FindChildTraverse('BuildTutorial').style.visibility = 'visible'
  }
  GameEvents.Subscribe('buildingStartPreview', OnStartPreview)

  function StopPreview () {
    previewActive = false
    blocked = false
    Particles.DestroyParticleEffect(previewParticle, true)
    Particles.ReleaseParticleIndex(previewParticle)
    previewParticle = null

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
      blocked = true
    } else {
      squareParticles.forEach(function (square) {
        Particles.SetParticleControl(square, 1, [150, 255, 150])
      })
      Particles.SetParticleControl(previewParticle, 2, [150, 255, 150])
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
          $.Msg('blocked')
        } else {
          var queue = GameUI.IsShiftDown()
          GameEvents.SendCustomGameEventToServer('buildingRequestConstruction', {'origin': worldPos, 'investmentName': investmentName, 'queue': queue, 'rotation': rotation})
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
