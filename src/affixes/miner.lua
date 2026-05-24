-- src/affixes/miner.lua
local C = require("src.constants")
local E = C.EFFECT
local Miner = { prefixes={}, suffixes={} }

Miner.prefixes = {
  {
    id="deep_driller", name="Deep-Driller", effect=E.SPEED_BONUS,
    description="+{value}% mining speed, +50% energy",
    tiers={
      {min=0.20,max=0.35,weight=60},
      {min=0.40,max=0.60,weight=25},
    },
    linked_effect={effect=E.CONSUMPTION, value=0.50},
  },
  {
    id="vein_reader", name="Vein-Reader", effect=E.PRODUCTIVITY,
    description="+{value}% mining yield",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.05,max=0.10,weight=70},
      {min=0.12,max=0.20,weight=30},
    },
  },
  {
    id="ore_blind", name="Ore-Blind", effect=E.RESOURCE_SPECIFIC,
    description="{value}% chance to output wrong ore type",
    scramble=true,
    tiers={
      {min=0.05,max=0.10,weight=40},
    },
  },
}

Miner.suffixes = {
  {
    id="of_rich_veins", name="of Rich Veins", effect=E.DUPLICATE_OUTPUT,
    description="+{value}% chance to output double ore",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.05,max=0.10,weight=65},
      {min=0.12,max=0.18,weight=25},
    },
  },
  {
    id="of_dust", name="of Dust", effect=E.DELETE_OUTPUT,
    description="{value}% chance ore is lost to dust",
    tiers={
      {min=0.03,max=0.06,weight=55},
      {min=0.07,max=0.12,weight=20},
    },
  },
}

return Miner
