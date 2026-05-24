-- prototypes/recipes.lua

local C = require("src.constants")

-- ── Forge recipe ──────────────────────────────────────────────────────────────
data:extend({{
  type    = "recipe",
  name    = C.FORGE_ITEM,
  enabled = false,
  ingredients = {
    {type="item", name="assembling-machine-3", amount=1},
    {type="item", name="steel-plate",          amount=20},
    {type="item", name="advanced-circuit",     amount=10},
  },
  results = {{type="item", name=C.FORGE_ITEM, amount=1}},
  energy_required = 10,
}})

-- ── Orb recipes ───────────────────────────────────────────────────────────────
-- Tier 1 orbs (unlocked with loot-orbs-1)
local tier1_recipes = {
  { name=C.ORB.TRANSMUTATION, enabled=false,
    ingredients={{type="item",name="iron-plate",amount=5},{type="item",name="copper-plate",amount=5}},
    time=5 },
  { name=C.ORB.ALTERATION, enabled=false,
    ingredients={{type="item",name="iron-plate",amount=10},{type="item",name="electronic-circuit",amount=2}},
    time=8 },
  { name=C.ORB.ALCHEMY, enabled=false,
    ingredients={{type="item",name="steel-plate",amount=5},{type="item",name="electronic-circuit",amount=5}},
    time=10 },
  { name=C.ORB.SCOURING, enabled=false,
    ingredients={{type="item",name="iron-plate",amount=8}},
    time=5 },
}

-- Tier 2 orbs (loot-orbs-2)
local tier2_recipes = {
  { name=C.ORB.CHAOS, enabled=false,
    ingredients={{type="item",name="steel-plate",amount=10},{type="item",name="advanced-circuit",amount=5}},
    time=15 },
  { name=C.ORB.AUGMENTATION, enabled=false,
    ingredients={{type="item",name="advanced-circuit",amount=5},{type="item",name="processing-unit",amount=2}},
    time=12 },
  { name=C.ORB.ANNULMENT, enabled=false,
    ingredients={{type="item",name="steel-plate",amount=5},{type="item",name="advanced-circuit",amount=3}},
    time=10 },
}

-- Tier 3 orbs (loot-orbs-3)
local tier3_recipes = {
  { name=C.ORB.EXALTATION, enabled=false,
    ingredients={{type="item",name="processing-unit",amount=10},{type="item",name="low-density-structure",amount=5}},
    time=20 },
  { name=C.ORB.BLESSED, enabled=false,
    ingredients={{type="item",name="processing-unit",amount=5},{type="item",name="utility-science-pack",amount=3}},
    time=20 },
}

for _, r in ipairs(tier1_recipes) do
  data:extend({{
    type="recipe", name=r.name, enabled=r.enabled,
    ingredients=r.ingredients,
    results={{type="item",name=r.name,amount=1}},
    energy_required=r.time,
  }})
end
for _, r in ipairs(tier2_recipes) do
  data:extend({{
    type="recipe", name=r.name, enabled=r.enabled,
    ingredients=r.ingredients,
    results={{type="item",name=r.name,amount=1}},
    energy_required=r.time,
  }})
end
for _, r in ipairs(tier3_recipes) do
  data:extend({{
    type="recipe", name=r.name, enabled=r.enabled,
    ingredients=r.ingredients,
    results={{type="item",name=r.name,amount=1}},
    energy_required=r.time,
  }})
end
