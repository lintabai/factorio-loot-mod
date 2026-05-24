-- src/naming.lua
-- Generates colored rich-text item/entity names from affix data.

local C       = require("src.constants")
local Affixes = require("src.affixes.init")

local Naming = {}

-- Build "Prefix1 Prefix2 Base Suffix1 Suffix2" string
function Naming.build_name(base_name, rarity, prefixes, suffixes)
  local parts = {}
  for _, inst in ipairs(prefixes or {}) do
    local def = Affixes.get_def(inst.id)
    if def then table.insert(parts, def.name) end
  end
  table.insert(parts, base_name)
  for _, inst in ipairs(suffixes or {}) do
    local def = Affixes.get_def(inst.id)
    if def then table.insert(parts, def.name) end
  end
  local name = table.concat(parts, " ")

  if rarity == C.RARITY.NORMAL then
    return name
  end
  local color = C.RARITY_COLOR[rarity] or "#ffffff"
  return "[color=" .. color .. "]" .. name .. "[/color]"
end

-- Format a value for display (percentages, integers, etc.)
function Naming.format_value(value)
  if value == math.floor(value) then
    return tostring(math.floor(value))
  end
  local pct = math.floor(math.abs(value) * 100 + 0.5)
  return tostring(pct) .. "%"
end

-- Build tooltip description lines for affixes
function Naming.build_tooltip(rarity, prefixes, suffixes)
  local lines = {"Rarity: " .. rarity}
  local function add_affixes(list)
    for _, inst in ipairs(list or {}) do
      local def = Affixes.get_def(inst.id)
      if def then
        local desc = def.description:gsub("{value}", Naming.format_value(inst.value))
        table.insert(lines, "  " .. def.name .. ": " .. desc)
      end
    end
  end
  add_affixes(prefixes)
  add_affixes(suffixes)
  return table.concat(lines, "\n")
end

-- Get base display name for an entity prototype name
-- Falls back to cleaned-up prototype name if not in map
local DISPLAY_NAMES = {
  ["assembling-machine-1"] = "Assembling Machine",
  ["assembling-machine-2"] = "Assembling Machine Mk2",
  ["assembling-machine-3"] = "Assembling Machine Mk3",
  ["electric-mining-drill"] = "Mining Drill",
  ["burner-mining-drill"]   = "Burner Drill",
  ["stone-furnace"]         = "Stone Furnace",
  ["steel-furnace"]         = "Steel Furnace",
  ["electric-furnace"]      = "Electric Furnace",
  ["burner-inserter"]       = "Burner Inserter",
  ["inserter"]              = "Inserter",
  ["long-handed-inserter"]  = "Long Inserter",
  ["fast-inserter"]         = "Fast Inserter",
  ["filter-inserter"]       = "Filter Inserter",
  ["stack-inserter"]        = "Stack Inserter",
  ["stack-filter-inserter"] = "Stack Filter Inserter",
  ["small-electric-pole"]   = "Small Electric Pole",
  ["medium-electric-pole"]  = "Medium Electric Pole",
  ["big-electric-pole"]     = "Big Electric Pole",
  ["substation"]            = "Substation",
  ["lab"]                   = "Lab",
  ["biolab"]                = "Biolab",
  ["chemical-plant"]        = "Chemical Plant",
  ["oil-refinery"]          = "Oil Refinery",
  ["boiler"]                = "Boiler",
  ["steam-engine"]          = "Steam Engine",
  ["steam-turbine"]         = "Steam Turbine",
  ["iron-chest"]            = "Iron Chest", -- armor item names
  ["light-armor"]           = "Light Armor",
  ["heavy-armor"]           = "Heavy Armor",
  ["modular-armor"]         = "Modular Armor",
  ["power-armor"]           = "Power Armor",
  ["power-armor-mk2"]       = "Power Armor Mk2",
}

function Naming.get_base_name(prototype_name)
  if DISPLAY_NAMES[prototype_name] then
    return DISPLAY_NAMES[prototype_name]
  end
  -- Fallback: title-case the prototype name
  local name = prototype_name:gsub("-", " ")
  return name:gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest
  end)
end

return Naming
