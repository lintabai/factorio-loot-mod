-- src/affixes/generic.lua
-- Affixes available to all rollable entity types.
-- Tiers: { min, max, weight }  (weight = relative probability within the tier list)

local C = require("src.constants")
local E = C.EFFECT

local Generic = { prefixes = {}, suffixes = {} }

-- ── Prefixes ─────────────────────────────────────────────────────────────────

Generic.prefixes = {
  {
    id="swift", name="Swift", effect=E.SPEED_BONUS,
    description="+{value}% operating speed",
    tiers={
      {min=0.10,max=0.15,weight=100},
      {min=0.20,max=0.30,weight=60},
      {min=0.35,max=0.50,weight=20},
    },
  },
  {
    id="sluggish", name="Sluggish", effect=E.SPEED_BONUS,
    description="{value}% operating speed",
    tiers={
      {min=-0.15,max=-0.10,weight=80},
      {min=-0.30,max=-0.20,weight=40},
      {min=-0.50,max=-0.35,weight=15},
    },
  },
  {
    id="efficient", name="Efficient", effect=E.CONSUMPTION,
    description="{value}% energy consumption",
    tiers={
      {min=-0.20,max=-0.10,weight=100},
      {min=-0.40,max=-0.25,weight=55},
      {min=-0.60,max=-0.45,weight=15},
    },
  },
  {
    id="wasteful", name="Wasteful", effect=E.CONSUMPTION,
    description="+{value}% energy consumption",
    tiers={
      {min=0.15,max=0.25,weight=80},
      {min=0.30,max=0.50,weight=40},
      {min=0.60,max=1.00,weight=12},
    },
  },
  {
    id="clean", name="Clean", effect=E.POLLUTION,
    description="{value}% pollution output",
    tiers={
      {min=-0.30,max=-0.20,weight=90},
      {min=-0.60,max=-0.35,weight=45},
      {min=-0.80,max=-0.65,weight=12},
    },
  },
  {
    id="polluting", name="Polluting", effect=E.POLLUTION,
    description="+{value}% pollution output",
    tiers={
      {min=0.30,max=0.60,weight=70},
      {min=0.80,max=1.20,weight=35},
      {min=1.50,max=2.50,weight=10},
    },
  },
  {
    id="overclocked", name="Overclocked", effect=E.SPEED_BONUS,
    description="+{value}% speed / +100% energy (linked)",
    -- Overclocked always applies a coupled consumption bonus in applicator
    tiers={
      {min=0.30,max=0.40,weight=30},
      {min=0.45,max=0.60,weight=15},
    },
    linked_effect={ effect=E.CONSUMPTION, multiplier=1.0 }, -- +100% consumption
  },
  {
    id="haunted", name="Haunted", effect=E.STALL,
    description="Randomly stalls for {value}s",
    tiers={
      {min=2,max=4,weight=60},   -- stall duration in seconds
      {min=5,max=8,weight=30},
      {min=9,max=15,weight=10},
    },
    stall_interval={ min=30, max=90 }, -- seconds between stall events
  },
  {
    id="prolific", name="Prolific", effect=E.PRODUCTIVITY,
    description="+{value}% productivity",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.02,max=0.04,weight=80},
      {min=0.06,max=0.09,weight=40},
      {min=0.10,max=0.14,weight=12},
    },
  },
}

-- ── Suffixes ──────────────────────────────────────────────────────────────────

Generic.suffixes = {
  {
    id="of_abundance", name="of Abundance", effect=E.DUPLICATE_OUTPUT,
    description="+{value}% chance to duplicate output",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.02,max=0.04,weight=90},
      {min=0.05,max=0.08,weight=45},
      {min=0.09,max=0.12,weight=12},
    },
  },
  {
    id="of_the_void", name="of the Void", effect=E.DELETE_OUTPUT,
    description="{value}% chance output is silently deleted",
    tiers={
      {min=0.005,max=0.015,weight=60},
      {min=0.02, max=0.04, weight=30},
      {min=0.045,max=0.06, weight=8},
    },
  },
  {
    id="of_silence", name="of Silence", effect=E.POLLUTION,
    description="Zero pollution, -10% speed (fixed)",
    -- Fixed stats: pollution=0 (set to -1.0 bonus i.e. fully cancels), speed-0.10
    tiers={
      {min=-1.0,max=-1.0,weight=40},
    },
    linked_effect={ effect=E.SPEED_BONUS, value=-0.10 },
  },
  {
    id="of_the_ancients", name="of the Ancients", effect=E.SPEED_BONUS,
    description="All stats x1.5, energy x3 (fixed)",
    tiers={
      {min=0.50,max=0.50,weight=15},
    },
    linked_effect={ effect=E.CONSUMPTION, value=2.0 }, -- +200% = x3
  },
  {
    id="of_ruin", name="of Ruin", effect=E.DELETE_OUTPUT,
    description="{value}% chance to lose entire input batch",
    tiers={
      {min=0.01,max=0.02,weight=50},
      {min=0.03,max=0.05,weight=20},
    },
    is_input_loss=true, -- special flag: deletes input, not output
  },
}

return Generic
