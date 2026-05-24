-- prototypes/items.lua
-- Orb currency items + Forge item

local C = require("src.constants")

local orb_definitions = {
  { name=C.ORB.TRANSMUTATION, icon="__base__/graphics/icons/copper-ore.png",      order="a", description="Upgrades a Normal item to Magic rarity." },
  { name=C.ORB.ALTERATION,    icon="__base__/graphics/icons/iron-ore.png",         order="b", description="Rerolls all affixes on a Magic item." },
  { name=C.ORB.ALCHEMY,       icon="__base__/graphics/icons/stone.png",            order="c", description="Upgrades a Normal item to Rare rarity." },
  { name=C.ORB.CHAOS,         icon="__base__/graphics/icons/coal.png",             order="d", description="Rerolls all affixes on a Rare item." },
  { name=C.ORB.AUGMENTATION,  icon="__base__/graphics/icons/copper-cable.png",     order="e", description="Adds one affix to an item with an open slot." },
  { name=C.ORB.ANNULMENT,     icon="__base__/graphics/icons/iron-stick.png",       order="f", description="Removes one random affix from an item." },
  { name=C.ORB.SCOURING,      icon="__base__/graphics/icons/empty-barrel.png",     order="g", description="Strips all affixes. Item becomes Normal." },
  { name=C.ORB.EXALTATION,    icon="__base__/graphics/icons/electronic-circuit.png", order="h", description="Adds one affix to a Rare or higher item with an open slot." },
  { name=C.ORB.BLESSED,       icon="__base__/graphics/icons/advanced-circuit.png", order="i", description="Rerolls affix values only. Keeps which affixes." },
}

for _, def in ipairs(orb_definitions) do
  data:extend({{
    type        = "item",
    name        = def.name,
    icon        = def.icon,
    icon_size   = 64,
    subgroup    = "loot-orbs",
    order       = def.order,
    stack_size  = 200,
    localised_description = {def.name .. "-description"},
  }})
end

-- Forge item (places the Forge entity)
data:extend({{
  type       = "item",
  name       = C.FORGE_ITEM,
  icon       = "__base__/graphics/icons/assembling-machine-3.png",
  icon_size  = 64,
  subgroup   = "loot-buildings",
  order      = "a",
  stack_size = 1,
  place_result = C.FORGE_ENTITY,
}})
