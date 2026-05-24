-- src/affixes/inserter.lua
local C = require("src.constants")
local E = C.EFFECT
local Inserter = { prefixes={}, suffixes={} }

Inserter.prefixes = {
  {
    id="nimble", name="Nimble", effect=E.SPEED_BONUS,
    description="+{value}% rotation speed",
    tiers={
      {min=0.15,max=0.25,weight=90},
      {min=0.30,max=0.50,weight=40},
    },
  },
  {
    id="clumsy", name="Clumsy", effect=E.SPEED_BONUS,
    description="{value}% rotation speed",
    tiers={
      {min=-0.20,max=-0.12,weight=70},
      {min=-0.40,max=-0.25,weight=25},
    },
  },
  {
    id="stack_gifted", name="Stack-Gifted", effect=E.PRODUCTIVITY,
    description="+{value} stack size bonus",
    -- Implemented via LuaEntity.inserter_stack_size_override
    is_stack_bonus=true,
    tiers={
      {min=1,max=1,weight=70},
      {min=2,max=2,weight=30},
      {min=3,max=3,weight=10},
    },
  },
  {
    id="fumbling", name="Fumbling", effect=E.DELETE_OUTPUT,
    description="{value}% chance to drop item on the ground",
    is_drop=true,
    tiers={
      {min=0.03,max=0.06,weight=50},
      {min=0.07,max=0.12,weight=20},
    },
  },
}

Inserter.suffixes = {
  {
    id="of_reach", name="of Reach", effect=E.SPEED_BONUS,
    description="+{value} tile reach extension",
    -- Implemented via prototype override at placement (needs custom entity subtype)
    -- v0.1: cosmetic, noted as TODO for runtime extension
    is_reach_bonus=true,
    tiers={
      {min=1,max=1,weight=50},
    },
  },
  {
    id="of_misplacement", name="of Misplacement", effect=E.DELETE_OUTPUT,
    description="{value}% chance item lands in wrong slot",
    is_misplace=true,
    tiers={
      {min=0.05,max=0.10,weight=40},
    },
  },
}

return Inserter
