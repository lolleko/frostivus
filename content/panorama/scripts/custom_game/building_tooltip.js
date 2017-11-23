var init = false

function SetupTooltip () {
  var buildingName = $.GetContextPanel().GetAttributeString('buildingName', undefined)

  if (init) {
    return
  }
  init = true
  var buildings = Players.GetBuildingShopKV(Players.GetLocalPlayer())
  var building = buildings[buildingName]
  var prevBuilding = buildings[buildingName.slice(0, -1) + (building.Level - 1)]
  if (!prevBuilding) {
    // create dummy
    prevBuilding = {
      Requirements: {}
    }
  }

  if (!building) {
    return
  }

  // hack because we cant overwirt ein css
  $.GetContextPanel().style.backgroundColor = '#10171C'

  $('#NameLabel').text = $.Localize('#' + buildingName)
  $('#TierLabel').text = $.Localize('#frostivus_tooltip_tier') + ' ' + building.Level
  $('#DescriptionLabel').text = $.Localize('#' + buildingName + '_Description')

  // LoadStat('#frostivus_tooltip_tier', building.Level, 's2r://panorama/images/hud/reborn/levelup_plus_fill_psd.vtex')
  if (building.Requirements.Buildings) {
    var reqbuildings = building.Requirements.Buildings.split(';')
    var reqBuildingsTooltip = ''
    for (var i = 0; i < reqbuildings.length; i++) {
      var tier = reqbuildings[i].slice(-1)
      reqBuildingsTooltip += $.Localize(reqbuildings[i])
      if (!isNaN(parseInt(tier, 10))) {
        reqBuildingsTooltip += ' Tier ' + '1'
      }
      if (i + 1 < reqbuildings.length) {
        reqBuildingsTooltip += '\n'
      }
    }
  }
  LoadStat('#frostivus_tooltip_required_buildings', reqBuildingsTooltip, null)
  LoadStat('#frostivus_tooltip_max_amount', building.Requirements.MaxAlive, null)
  LoadStat('#frostivus_tooltip_gold_cost', building.Requirements.GoldCost, null)
  LoadStat('#frostivus_tooltip_lumber_cost', building.Requirements.LumberCost, null)
  LoadStat('#frostivus_tooltip_armor', building.ArmorPhysical, prevBuilding.ArmorPhysical)
  LoadStat('#frostivus_tooltip_health', building.StatusHealth, prevBuilding.StatusHealth)
  LoadStat('#frostivus_tooltip_healt_regen', building.StatusHealthRegen, prevBuilding.StatusHealthRegen)
  if (building.SizeX !== 0 && building.SizeY !== 0) {
    LoadStat('#frostivus_tooltip_size', building.SizeX + ' x ' + building.SizeY, null)
  }
  LoadStat('#frostivus_tooltip_damage', (building.AttackDamageMin + building.AttackDamageMax) / 2, (prevBuilding.AttackDamageMin + prevBuilding.AttackDamageMax) / 2)
  LoadStat('#frostivus_tooltip_attack_range', building.AttackRange, prevBuilding.AttackRange)
  LoadStat('#frostivus_tooltip_attack_rate', building.AttackRate, prevBuilding.AttackRate)
}

function LoadStat (name, value, prevValue) {
  var compareWithPrevTier = $.GetContextPanel().GetAttributeString('compareWithPrevTier', false)

  if (!value) {
      // skip
    return
  }
  var parent = $('#StatsPanel')
  var panel = $.CreatePanel('Panel', parent, name + 'Panel')
  panel.AddClass('StatPanel')
  var nameLabel = $.CreatePanel('Label', panel, name + 'Name')
  nameLabel.text = $.Localize(name) + ':'
  nameLabel.AddClass('StatName')

  var valueLabel = $.CreatePanel('Label', panel, name + 'Value')
  if (!compareWithPrevTier || !prevValue || value === prevValue) {
    valueLabel.text = value
  } else {
    valueLabel.text = prevValue + ' -> ' + value
  }
  valueLabel.AddClass('StatValue')
}
