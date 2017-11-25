-- Do not polute gobal NS with every single quest
QuestList = {}

QuestList.frostivus_quest_starter_kill_enemies = require "quests.frostivus_quest_starter_kill_enemies"
QuestList.frostivus_quest_starter_lumber_camp = require "quests.frostivus_quest_starter_lumber_camp"
QuestList.frostivus_quest_starter_build_sentry = require "quests.frostivus_quest_starter_build_sentry"
QuestList.frostivus_quest_starter_build_walls = require "quests.frostivus_quest_starter_build_walls"
QuestList.frostivus_quest_starter_gold_camp = require "quests.frostivus_quest_starter_gold_camp"
QuestList.frostivus_quest_summon_roshan = require "quests.frostivus_quest_summon_roshan"
QuestList.frostivus_quest_kill_roshan = require "quests.frostivus_quest_kill_roshan"
QuestList.frostivus_quest_destroy_snow_makers = require "quests.frostivus_quest_destroy_snow_makers"
QuestList.frostivus_quest_kill_storegga = require "quests.frostivus_quest_kill_storegga"
  -- events
QuestList.frostivus_event_zombie_army = require "quests.frostivus_event_zombie_army"
QuestList.frostivus_event_skeleton_army = require "quests.frostivus_event_skeleton_army"
QuestList.frostivus_event_item_drop = require "quests.frostivus_event_item_drop"

GameMode.EventList = {
  {
    class = QuestList.frostivus_event_zombie_army,
    stages = {0, 1},
    cooldown = 1200,
    weight = 4,
  },
  {
    class = QuestList.frostivus_event_skeleton_army,
    stages = {0},
    cooldown = 900,
    weight = 7,
  },
  {
    class = QuestList.frostivus_event_item_drop,
    stages = {0, 1, 2},
    cooldown = 1200,
    small = true,
    weight = 4,
  },
  -- {
  --   class = GreevilsOnTheRun,
  --   stages = {0, 1, 2},
  --   cooldown = 1200,
  --   weight = 3,
  -- }
}
