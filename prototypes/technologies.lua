-- prototypes/technologies.lua
-- Full research tree for the Loot & Rarity mod.

-- Rarity unlock techs
data:extend({
  -- ── Rarity I: Magic ──────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-rarity-1",
    localised_name = {"technology-name.loot-rarity-1"},
    icon = "__base__/graphics/technology/automation.png",
    icon_size = 256,
    prerequisites = {"automation"},
    unit = {
      count = 50,
      ingredients = {{"automation-science-pack", 1}},
      time = 30,
    },
    effects = {},
  },

  -- ── Rarity II: Rare ──────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-rarity-2",
    localised_name = {"technology-name.loot-rarity-2"},
    icon = "__base__/graphics/technology/logistic-science-pack.png",
    icon_size = 256,
    prerequisites = {"loot-rarity-1", "logistic-science-pack"},
    unit = {
      count = 150,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
      },
      time = 45,
    },
    effects = {},
  },

  -- ── Rarity III: Epic ─────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-rarity-3",
    localised_name = {"technology-name.loot-rarity-3"},
    icon = "__base__/graphics/technology/chemical-science-pack.png",
    icon_size = 256,
    prerequisites = {"loot-rarity-2", "chemical-science-pack"},
    unit = {
      count = 300,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"chemical-science-pack",   1},
      },
      time = 60,
    },
    effects = {},
  },

  -- ── Rarity IV: Legendary ─────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-rarity-4",
    localised_name = {"technology-name.loot-rarity-4"},
    icon = "__base__/graphics/technology/utility-science-pack.png",
    icon_size = 256,
    prerequisites = {"loot-rarity-3", "space-science-pack"},
    unit = {
      count = 1000,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
        {"chemical-science-pack",   1},
        {"production-science-pack", 1},
        {"utility-science-pack",    1},
        {"space-science-pack",      1},
      },
      time = 120,
    },
    effects = {},
  },

  -- ── Forge ────────────────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-forge",
    localised_name = {"technology-name.loot-forge"},
    icon = "__base__/graphics/technology/advanced-electronics.png",
    icon_size = 256,
    prerequisites = {"loot-rarity-1"},
    unit = {
      count = 75,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack",   1},
      },
      time = 30,
    },
    effects = {
      {type="unlock-recipe", recipe="loot-tinkerers-forge"},
    },
  },

  -- ── Orb Crafting I ───────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-orbs-1",
    localised_name = {"technology-name.loot-orbs-1"},
    icon = "__base__/graphics/technology/automation-2.png",
    icon_size = 256,
    prerequisites = {"loot-forge"},
    unit = {
      count = 50,
      ingredients = {{"automation-science-pack",1},{"logistic-science-pack",1}},
      time = 30,
    },
    effects = {
      {type="unlock-recipe", recipe="loot-orb-transmutation"},
      {type="unlock-recipe", recipe="loot-orb-alteration"},
      {type="unlock-recipe", recipe="loot-orb-alchemy"},
      {type="unlock-recipe", recipe="loot-orb-scouring"},
    },
  },

  -- ── Orb Crafting II ──────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-orbs-2",
    localised_name = {"technology-name.loot-orbs-2"},
    icon = "__base__/graphics/technology/advanced-electronics.png",
    icon_size = 256,
    prerequisites = {"loot-orbs-1", "loot-rarity-2"},
    unit = {
      count = 150,
      ingredients = {
        {"automation-science-pack",1},{"logistic-science-pack",1},{"chemical-science-pack",1},
      },
      time = 45,
    },
    effects = {
      {type="unlock-recipe", recipe="loot-orb-chaos"},
      {type="unlock-recipe", recipe="loot-orb-augmentation"},
      {type="unlock-recipe", recipe="loot-orb-annulment"},
    },
  },

  -- ── Orb Crafting III ─────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-orbs-3",
    localised_name = {"technology-name.loot-orbs-3"},
    icon = "__base__/graphics/technology/advanced-electronics-2.png",
    icon_size = 256,
    prerequisites = {"loot-orbs-2", "loot-rarity-3"},
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack",1},{"logistic-science-pack",1},
        {"chemical-science-pack",1},{"production-science-pack",1},
      },
      time = 60,
    },
    effects = {
      {type="unlock-recipe", recipe="loot-orb-exaltation"},
      {type="unlock-recipe", recipe="loot-orb-blessed"},
    },
  },

  -- ── Affix Mastery I (resource-specific affixes) ──────────────────────────
  {
    type = "technology",
    name = "loot-affixes-1",
    localised_name = {"technology-name.loot-affixes-1"},
    icon = "__base__/graphics/technology/modules.png",
    icon_size = 256,
    prerequisites = {"loot-rarity-2"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack",1},{"logistic-science-pack",1},{"chemical-science-pack",1},
      },
      time = 45,
    },
    effects = {},
  },

  -- ── Affix Mastery II (entity-specific affixes) ───────────────────────────
  {
    type = "technology",
    name = "loot-affixes-2",
    localised_name = {"technology-name.loot-affixes-2"},
    icon = "__base__/graphics/technology/advanced-material-processing-2.png",
    icon_size = 256,
    prerequisites = {"loot-affixes-1", "loot-rarity-3"},
    unit = {
      count = 400,
      ingredients = {
        {"automation-science-pack",1},{"logistic-science-pack",1},
        {"chemical-science-pack",1},{"production-science-pack",1},
      },
      time = 60,
    },
    effects = {},
  },

  -- ── Affix Mastery III (legendary-only affixes) ───────────────────────────
  {
    type = "technology",
    name = "loot-affixes-3",
    localised_name = {"technology-name.loot-affixes-3"},
    icon = "__base__/graphics/technology/research-speed-6.png",
    icon_size = 256,
    prerequisites = {"loot-affixes-2", "loot-rarity-4"},
    unit = {
      count = 1000,
      ingredients = {
        {"automation-science-pack",1},{"logistic-science-pack",1},{"chemical-science-pack",1},
        {"production-science-pack",1},{"utility-science-pack",1},{"space-science-pack",1},
      },
      time = 120,
    },
    effects = {},
  },

  -- ── Lab Affixes ──────────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-lab-affixes",
    localised_name = {"technology-name.loot-lab-affixes"},
    icon = "__base__/graphics/technology/research-productivity.png",
    icon_size = 256,
    prerequisites = {"loot-affixes-2"},
    unit = {
      count = 300,
      ingredients = {
        {"automation-science-pack",1},{"logistic-science-pack",1},
        {"chemical-science-pack",1},{"production-science-pack",1},
      },
      time = 60,
    },
    effects = {},
  },

  -- ── Armor Affixes ────────────────────────────────────────────────────────
  {
    type = "technology",
    name = "loot-armor-affixes",
    localised_name = {"technology-name.loot-armor-affixes"},
    icon = "__base__/graphics/technology/power-armor.png",
    icon_size = 256,
    prerequisites = {"loot-affixes-2"},
    unit = {
      count = 300,
      ingredients = {
        {"automation-science-pack",1},{"logistic-science-pack",1},
        {"chemical-science-pack",1},{"production-science-pack",1},
      },
      time = 60,
    },
    effects = {},
  },
})
