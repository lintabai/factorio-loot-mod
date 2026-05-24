-- src/affixes/furnace.lua
local C = require("src.constants")
local E = C.EFFECT
local Furnace = { prefixes={}, suffixes={} }

Furnace.prefixes = {
  {
    id="blazing", name="Blazing", effect=E.SPEED_BONUS,
    description="+{value}% smelting speed",
    tiers={
      {min=0.15,max=0.25,weight=80},
      {min=0.30,max=0.50,weight=35},
    },
  },
  {
    id="cold", name="Cold", effect=E.SPEED_BONUS,
    description="{value}% smelting speed",
    tiers={
      {min=-0.20,max=-0.12,weight=70},
      {min=-0.40,max=-0.25,weight=30},
    },
  },
  {
    id="fuel_sipping", name="Fuel-Sipping", effect=E.CONSUMPTION,
    description="{value}% fuel consumption",
    tiers={
      {min=-0.20,max=-0.12,weight=80},
      {min=-0.40,max=-0.25,weight=35},
    },
  },
  {
    id="fuel_hungry_furnace", name="Fuel-Hungry", effect=E.CONSUMPTION,
    description="+{value}% fuel consumption",
    tiers={
      {min=0.20,max=0.40,weight=65},
      {min=0.50,max=0.80,weight=25},
    },
  },
}

Furnace.suffixes = {
  {
    id="of_pure_metal", name="of Pure Metal", effect=E.DUPLICATE_OUTPUT,
    description="+{value}% chance for bonus ingot",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.05,max=0.10,weight=70},
      {min=0.12,max=0.18,weight=28},
    },
  },
  {
    id="of_slag", name="of Slag", effect=E.RESOURCE_SPECIFIC,
    description="{value}% chance to produce stone as byproduct",
    is_slag=true,
    tiers={
      {min=0.08,max=0.15,weight=45},
    },
  },
}

return Furnace
