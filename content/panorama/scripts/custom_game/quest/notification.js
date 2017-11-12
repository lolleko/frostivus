(function () {
  $.GetContextPanel().LoadQuest = function (quest) {
    $('#NotificationQuestName').text = $.Localize('#' + quest.questName)
    $('#NotificationQuestDescription').text = $.Localize('#' + quest.questName + '_completed_Description')
    $.Msg(quest)
    for (var resourceName in quest.rewards.resource) {
      var resourceReward = quest.rewards.resource[resourceName]
      var resourPanel = $.CreatePanel('Panel', $('#NotificationRewards'), 'NotificationReward' + resourceName + 'Panel')
      resourPanel.AddClass('NotificationReward')
      var resourceIcon = $.CreatePanel('Panel', resourPanel, 'NotificationReward' + resourceName + 'Icon')
      resourceIcon.AddClass('NotificationIcon' + resourceName)
      resourceIcon.AddClass('NotificationIcon')
      var resourceLbl = $.CreatePanel('Label', resourPanel, 'NotificationReward' + resourceName + 'Label')
      resourceLbl.AddClass('NotificationRewardLabel')
      resourceLbl.text = resourceReward
    }
    $.GetContextPanel().AddClass('QuestNotificationPopup')
    $.GetContextPanel().DeleteAsync(8)
  }
}())
