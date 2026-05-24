-- prototypes/entities.lua
-- Tinkerer's Forge entity (container, 2 slots)

local C = require("src.constants")

data:extend({{
  type            = "container",
  name            = C.FORGE_ENTITY,
  localised_name  = {"entity-name.loot-tinkerers-forge"},
  icon            = "__base__/graphics/icons/assembling-machine-3.png",
  icon_size       = 64,
  flags           = {"placeable-neutral", "player-creation"},
  minable         = {
    mining_time = 0.5,
    result      = C.FORGE_ITEM,
  },
  max_health      = 300,
  corpse          = "medium-remnants",
  collision_box   = {{-1.2, -1.2}, {1.2, 1.2}},
  selection_box   = {{-1.5, -1.5}, {1.5, 1.5}},
  inventory_size  = 2,
  -- Use assembling-machine-3 graphics as placeholder
  picture = {
    filename  = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3.png",
    priority  = "extra-high",
    width     = 214,
    height    = 226,
    shift     = {0.03125, 0.0},
    scale     = 0.5,
  },
  open_sound  = { filename = "__base__/sound/machine-open.ogg",  volume = 0.85 },
  close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
}})
