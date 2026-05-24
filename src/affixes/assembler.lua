-- src/affixes/assembler.lua
-- Affixes exclusive to assembling-machine entities.
-- Resource-specific affixes require loot-affixes-1 research.

local C = require("src.constants")
local E = C.EFFECT

local Assembler = { prefixes = {}, suffixes = {} }

-- ── Resource-specific prefixes (need loot-affixes-1) ─────────────────────────
-- effect = RESOURCE_SPECIFIC, resource = item name or "all_plates"/"all_fluids"
-- Implemented via post-craft inventory correction (on_nth_tick scanner)

Assembler.prefixes = {
  {
    id="iron_efficient", name="Iron-Efficient", effect=E.RESOURCE_SPECIFIC,
    resource="iron-plate", sign=-1,
    description="{value}% iron plate consumption",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.15,max=0.20,weight=80},
      {min=0.25,max=0.35,weight=40},
    },
  },
  {
    id="iron_hungry", name="Iron-Hungry", effect=E.RESOURCE_SPECIFIC,
    resource="iron-plate", sign=1,
    description="+{value}% iron plate consumption",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.20,max=0.40,weight=70},
      {min=0.45,max=0.80,weight=30},
    },
  },
  {
    id="copper_efficient", name="Copper-Efficient", effect=E.RESOURCE_SPECIFIC,
    resource="copper-plate", sign=-1,
    description="{value}% copper plate consumption",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.15,max=0.20,weight=80},
      {min=0.25,max=0.35,weight=40},
    },
  },
  {
    id="copper_hungry", name="Copper-Hungry", effect=E.RESOURCE_SPECIFIC,
    resource="copper-plate", sign=1,
    description="+{value}% copper plate consumption",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.20,max=0.40,weight=70},
      {min=0.45,max=0.80,weight=30},
    },
  },
  {
    id="steel_substituting", name="Steel-Substituting", effect=E.RESOURCE_SPECIFIC,
    resource="iron-plate", replace_with="steel-plate", replace_ratio=0.5, sign=1,
    description="Replaces 50% of iron with steel (uses half as many steel)",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.50,max=0.50,weight=25},
    },
  },
  {
    id="fluid_efficient", name="Fluid-Efficient", effect=E.RESOURCE_SPECIFIC,
    resource="__fluid__", sign=-1,
    description="{value}% fluid ingredient consumption",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.15,max=0.25,weight=70},
      {min=0.30,max=0.45,weight=30},
    },
  },
  {
    id="fluid_wasteful", name="Fluid-Wasteful", effect=E.RESOURCE_SPECIFIC,
    resource="__fluid__", sign=1,
    description="+{value}% fluid ingredient consumption",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.25,max=0.50,weight=55},
      {min=0.55,max=1.00,weight=20},
    },
  },
  {
    id="plate_hungry", name="Plate-Hungry", effect=E.RESOURCE_SPECIFIC,
    resource="__plate__", sign=1,
    description="+{value}% all plate consumption, +10% speed",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.30,max=0.50,weight=35},
      {min=0.55,max=0.80,weight=15},
    },
    linked_effect={ effect=E.SPEED_BONUS, value=0.10 },
  },
  {
    id="circuit_scavenging", name="Circuit-Scavenging", effect=E.RESOURCE_SPECIFIC,
    resource="__circuit__", sign=-1, is_chance=true, chance=0.15,
    description="15% chance to recover one used circuit component",
    requires_research="loot-affixes-1",
    tiers={
      {min=0.15,max=0.15,weight=30},
    },
  },
  {
    id="ingredient_scrambled", name="Ingredient-Scrambled", effect=E.RESOURCE_SPECIFIC,
    resource="__random__", sign=1, scramble=true,
    description="Randomly swaps one ingredient type per craft",
    tiers={
      {min=1,max=1,weight=20},
    },
  },
}

Assembler.suffixes = {
  {
    id="of_experimentation", name="of Experimentation", effect=E.DUPLICATE_OUTPUT,
    description="Output may be a random quality tier",
    requires_research="loot-affixes-2",
    is_random_quality=true,
    tiers={
      {min=0.10,max=0.15,weight=40},
    },
  },
  {
    id="of_echoes", name="of Echoes", effect=E.DUPLICATE_OUTPUT,
    description="{value}% chance to produce a copy to adjacent belt",
    requires_research="loot-affixes-2",
    is_echo=true,
    tiers={
      {min=0.03,max=0.06,weight=30},
      {min=0.07,max=0.10,weight=12},
    },
  },
  {
    id="of_decay", name="of Decay", effect=E.DELETE_OUTPUT,
    description="{value}% chance output quality is degraded one tier",
    requires_research="loot-affixes-2",
    is_quality_downgrade=true,
    tiers={
      {min=0.05,max=0.08,weight=45},
      {min=0.09,max=0.12,weight=20},
    },
  },
  {
    id="of_the_prototype", name="of the Prototype", effect=E.SPEED_BONUS,
    description="+2 module slots (via beacon effect)",
    -- Implemented via hidden beacon with speed module in applicator
    requires_research="loot-affixes-2",
    extra_module_slots=2,
    tiers={{min=0,max=0,weight=20}},
  },
  {
    id="of_hunger", name="of Hunger", effect=E.CONSUMPTION,
    description="Never stalls for energy, +{value}% energy drain",
    requires_research="loot-affixes-1",
    no_energy_stall=true,
    tiers={
      {min=0.30,max=0.50,weight=35},
    },
  },
}

return Assembler
