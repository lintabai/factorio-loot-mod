-- prototypes/entities.lua
-- Tinkerer's Forge entity (container, 2 slots)
-- Uses iron-chest sprite as placeholder until custom art is added.

local C = require("src.constants")

data:extend({{
  type            = "container",
  name            = C.FORGE_ENTITY,
  localised_name  = {"entity-name.loot-tinkerers-forge"},
  icon            = "__base__/graphics/icons/iron-chest.png",
  icon_size       = 64,
  flags           = {"placeable-neutral", "player-creation"},
  minable         = {
    mining_time = 0.5,
    result      = C.FORGE_ITEM,
  },
  max_health    = 300,
  corpse        = "small-remnants",
  collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
  selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
  inventory_size = 2,
  picture = {
    layers = {
      {
        filename = "__base__/graphics/entity/iron-chest/iron-chest.png",
        priority = "extra-high",
        width    = 64,
        height   = 80,
        shift    = {0.03125, -0.125},
        scale    = 1.0,
      },
    },
  },
  open_sound  = { filename = "__base__/sound/metallic-chest-open.ogg",  volume = 0.65 },
  close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.65 },
}})
