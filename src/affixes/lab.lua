-- src/affixes/lab.lua
-- Labs have backer names (unique per entity), and Space Age adds distinct lab prototypes.
-- Science-type-specific affixes are gated to matching lab prototype names.

local C = require("src.constants")
local E = C.EFFECT
local Lab = { prefixes={}, suffixes={} }

-- ── Generic lab prefixes (all lab types) ─────────────────────────────────────

Lab.prefixes = {
  {
    id="power_sipping_lab", name="Power-Sipping", effect=E.CONSUMPTION,
    description="{value}% energy consumption",
    tiers={
      {min=-0.25,max=-0.15,weight=80},
      {min=-0.45,max=-0.30,weight=35},
    },
  },
  {
    id="power_hungry_lab", name="Power-Hungry", effect=E.CONSUMPTION,
    description="+{value}% energy consumption",
    tiers={
      {min=0.25,max=0.50,weight=65},
      {min=0.55,max=1.00,weight=25},
    },
  },
  {
    id="accelerated", name="Accelerated", effect=E.SPEED_BONUS,
    description="+{value}% research speed",
    tiers={
      {min=0.15,max=0.25,weight=75},
      {min=0.30,max=0.50,weight=32},
    },
  },
  {
    id="sluggish_lab", name="Sluggish", effect=E.SPEED_BONUS,
    description="{value}% research speed",
    tiers={
      {min=-0.20,max=-0.12,weight=60},
      {min=-0.35,max=-0.25,weight=25},
    },
  },
  {
    id="biter_attracting", name="Biter-Attracting", effect=E.SPAWN_BITERS,
    description="{value}% chance to spawn a biter wave when research completes",
    requires_research="loot-lab-affixes",
    tiers={
      {min=0.05,max=0.10,weight=40},
      {min=0.12,max=0.20,weight=18},
    },
  },
  {
    id="enlightened", name="Enlightened", effect=E.DUPLICATE_OUTPUT,
    description="{value}% chance for bonus research progress tick",
    requires_research="loot-lab-affixes",
    is_research_bonus=true,
    tiers={
      {min=0.05,max=0.10,weight=55},
      {min=0.12,max=0.18,weight=22},
    },
  },
  {
    id="overloaded_lab", name="Overloaded", effect=E.SPEED_BONUS,
    description="-20% research speed, processes 2 queued techs simultaneously",
    -- TODO: multi-tech processing needs deep scripting; v0.1 applies speed penalty only
    is_multi_tech=true,
    tiers={{min=-0.20,max=-0.20,weight=20}},
  },
}

-- ── Science-type-specific prefixes (gated by entity_name_filter) ─────────────

-- entity_name_filter: table of prototype names this affix can roll on.
-- nil = all labs.

Lab.science_prefixes = {
  -- Base lab (automation + logistic science)
  {
    id="automation_attuned", name="Automation-Attuned", effect=E.RESOURCE_SPECIFIC,
    resource="automation-science-pack", sign=-1,
    description="{value}% automation science pack consumption",
    entity_name_filter={"lab"},
    requires_research="loot-lab-affixes",
    tiers={{min=0.15,max=0.25,weight=60},{min=0.30,max=0.40,weight=25}},
  },
  {
    id="logistic_focused", name="Logistic-Focused", effect=E.RESOURCE_SPECIFIC,
    resource="logistic-science-pack", sign=-1,
    description="{value}% logistic science pack consumption",
    entity_name_filter={"lab"},
    requires_research="loot-lab-affixes",
    tiers={{min=0.15,max=0.25,weight=60},{min=0.30,max=0.40,weight=25}},
  },
  -- Military lab / base lab with military tech
  {
    id="military_drilled", name="Military-Drilled", effect=E.RESOURCE_SPECIFIC,
    resource="military-science-pack", sign=-1,
    description="{value}% military science pack consumption",
    entity_name_filter={"lab"},
    requires_research="loot-lab-affixes",
    tiers={{min=0.15,max=0.30,weight=55}},
  },
  -- Chemical/production science
  {
    id="chemical_calibrated", name="Chemical-Calibrated", effect=E.RESOURCE_SPECIFIC,
    resource="chemical-science-pack", sign=-1,
    description="{value}% chemical science pack consumption",
    entity_name_filter={"lab"},
    requires_research="loot-lab-affixes",
    tiers={{min=0.15,max=0.30,weight=50}},
  },
  -- Space Age: Biolab
  {
    id="bioengineered", name="Bioengineered", effect=E.SPEED_BONUS,
    description="+{value}% research speed in this lab",
    entity_name_filter={"biolab"},
    requires_research="loot-lab-affixes",
    tiers={{min=0.15,max=0.25,weight=50},{min=0.30,max=0.45,weight=20}},
  },
}

Lab.suffixes = {
  {
    id="of_overflow", name="of Overflow", effect=E.DELETE_OUTPUT,
    description="{value}% chance science pack consumed without progress",
    is_research_loss=true,
    tiers={
      {min=0.03,max=0.06,weight=55},
      {min=0.07,max=0.12,weight=22},
    },
  },
  {
    id="of_the_academy", name="of the Academy", effect=E.SPEED_BONUS,
    description="+30% research speed, x2 energy (fixed)",
    requires_research="loot-lab-affixes",
    tiers={{min=0.30,max=0.30,weight=18}},
    linked_effect={effect=E.CONSUMPTION, value=1.0},
  },
  {
    id="of_instability", name="of Instability", effect=E.STALL,
    description="Randomly pauses mid-research for {value}s",
    tiers={
      {min=3,max=6,weight=45},
      {min=7,max=12,weight=18},
    },
    stall_interval={min=60,max=180},
  },
}

return Lab
