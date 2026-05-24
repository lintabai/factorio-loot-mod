-- prototypes/item_groups.lua
-- Subgroup definitions for mod items

data:extend({
  {
    type  = "item-subgroup",
    name  = "loot-orbs",
    group = "intermediate-products",
    order = "z-loot-orbs",
  },
  {
    type  = "item-subgroup",
    name  = "loot-buildings",
    group = "production",
    order = "z-loot-buildings",
  },
})
