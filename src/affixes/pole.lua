-- src/affixes/pole.lua
-- NOTE: wire distance / supply area require prototype subclasses (not runtime-writable).
-- v0.1 implements these as informational affixes; runtime application noted as TODO.
local C = require("src.constants")
local E = C.EFFECT
local Pole = { prefixes={}, suffixes={} }

Pole.prefixes = {
  {
    id="long_range", name="Long-Range", effect=E.SPEED_BONUS,
    description="+{value}% wire connection distance",
    is_wire_distance=true, -- TODO: needs prototype subclass
    tiers={
      {min=0.20,max=0.35,weight=70},
      {min=0.40,max=0.60,weight=25},
    },
  },
  {
    id="short_range", name="Short-Range", effect=E.SPEED_BONUS,
    description="{value}% wire connection distance",
    is_wire_distance=true,
    tiers={
      {min=-0.25,max=-0.15,weight=55},
    },
  },
  {
    id="wide_area", name="Wide-Area", effect=E.SPEED_BONUS,
    description="+{value}% supply area",
    is_supply_area=true,
    tiers={
      {min=0.20,max=0.40,weight=65},
      {min=0.45,max=0.70,weight=22},
    },
  },
  {
    id="narrow_area", name="Narrow-Area", effect=E.SPEED_BONUS,
    description="{value}% supply area",
    is_supply_area=true,
    tiers={
      {min=-0.30,max=-0.20,weight=50},
    },
  },
}

Pole.suffixes = {
  {
    id="superconducting", name="Superconducting", effect=E.CONSUMPTION,
    description="-50% energy transmission loss",
    -- Applied as consumption_bonus modifier on the pole entity
    tiers={{min=-0.50,max=-0.50,weight=30}},
  },
  {
    id="corroded", name="Corroded", effect=E.CONSUMPTION,
    description="+{value}% energy transmission loss",
    tiers={
      {min=0.50,max=0.80,weight=55},
      {min=0.90,max=1.50,weight=20},
    },
  },
}

return Pole
