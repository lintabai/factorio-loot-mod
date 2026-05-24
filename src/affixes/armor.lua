-- src/affixes/armor.lua
-- Armor affixes are stored in item tags and applied to the player (LuaCharacter).
-- Applied on equip, removed on unequip. Tracked per-player in storage.

local C = require("src.constants")
local E = C.EFFECT
local Armor = { prefixes={}, suffixes={} }

Armor.prefixes = {
  {
    id="swift_armor", name="Swift", effect=E.MOVEMENT_BONUS,
    description="+{value}% movement speed",
    requires_research="loot-armor-affixes",
    tiers={
      {min=0.05,max=0.10,weight=80},
      {min=0.12,max=0.20,weight=35},
      {min=0.22,max=0.30,weight=10},
    },
  },
  {
    id="lumbering", name="Lumbering", effect=E.MOVEMENT_BONUS,
    description="{value}% movement speed",
    requires_research="loot-armor-affixes",
    tiers={
      {min=-0.10,max=-0.05,weight=65},
      {min=-0.20,max=-0.12,weight=25},
    },
  },
  {
    id="lucky_armor", name="Lucky", effect=E.LUCKY,
    description="Roll rarity {value} extra time(s), take best result",
    requires_research="loot-armor-affixes",
    tiers={
      {min=1,max=1,weight=50},
      {min=2,max=2,weight=18},
    },
  },
  {
    id="cursed_armor", name="Cursed", effect=E.CURSED,
    description="Roll rarity {value} extra time(s), take worst result",
    requires_research="loot-armor-affixes",
    tiers={
      {min=1,max=1,weight=40},
    },
  },
  {
    id="warded", name="Warded", effect=E.SPEED_BONUS,
    -- Approximated as a speed bonus; true resistance not scriptable per item
    description="+{value}% personal equipment recharge rate",
    requires_research="loot-armor-affixes",
    tiers={
      {min=0.10,max=0.20,weight=65},
      {min=0.25,max=0.40,weight=25},
    },
  },
}

Armor.suffixes = {
  {
    id="of_the_artificer", name="of the Artificer", effect=E.RARITY_BONUS,
    description="Items you hand-craft gain +1 rarity tier",
    requires_research="loot-armor-affixes",
    tiers={{min=1,max=1,weight=20}},
  },
  {
    id="of_reach", name="of Reach", effect=E.REACH_BONUS,
    description="+{value} tile character reach",
    requires_research="loot-armor-affixes",
    tiers={
      {min=1,max=2,weight=60},
      {min=3,max=4,weight=20},
    },
  },
  {
    id="of_misfortune", name="of Misfortune", effect=E.CURSED,
    description="All rarity rolls -1 tier",
    tiers={{min=1,max=1,weight=35}},
  },
  {
    id="of_the_engineer", name="of the Engineer", effect=E.SPEED_BONUS,
    description="+{value}% module efficiency in personal equipment grid",
    -- Approximated via character speed modifier as best available API
    requires_research="loot-armor-affixes",
    tiers={
      {min=0.05,max=0.10,weight=50},
    },
  },
}

return Armor
