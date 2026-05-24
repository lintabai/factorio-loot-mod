-- src/affixes/init.lua
-- Loads all affix tables and provides a unified pool resolver.

local Generic  = require("src.affixes.generic")
local Assembler= require("src.affixes.assembler")
local Miner    = require("src.affixes.miner")
local Furnace  = require("src.affixes.furnace")
local Inserter = require("src.affixes.inserter")
local Pole     = require("src.affixes.pole")
local Lab      = require("src.affixes.lab")
local Armor    = require("src.affixes.armor")

local Affixes = {}

-- Map entity type → entity-specific affix tables
local TYPE_MAP = {
  ["assembling-machine"] = Assembler,
  ["mining-drill"]       = Miner,
  ["furnace"]            = Furnace,
  ["inserter"]           = Inserter,
  ["electric-pole"]      = Pole,
  ["lab"]                = Lab,
  -- armor handled separately via get_armor_pool
}

-- Returns { prefixes = [...], suffixes = [...] } filtered by:
--   1. entity type (generic + type-specific)
--   2. entity prototype name (for entity_name_filter)
--   3. researched technologies for the given force
function Affixes.get_pool(entity_type, entity_name, force)
  local researched = {}
  if force then
    for tech_name, tech in pairs(force.technologies) do
      if tech.researched then researched[tech_name] = true end
    end
  end

  local function is_available(affix)
    if affix.requires_research and not researched[affix.requires_research] then
      return false
    end
    if affix.entity_name_filter then
      local match = false
      for _, n in ipairs(affix.entity_name_filter) do
        if n == entity_name then match = true; break end
      end
      if not match then return false end
    end
    return true
  end

  local prefixes, suffixes = {}, {}

  -- Generic affixes
  for _, a in ipairs(Generic.prefixes) do
    if is_available(a) then table.insert(prefixes, a) end
  end
  for _, a in ipairs(Generic.suffixes) do
    if is_available(a) then table.insert(suffixes, a) end
  end

  -- Type-specific affixes
  local specific = TYPE_MAP[entity_type]
  if specific then
    for _, a in ipairs(specific.prefixes or {}) do
      if is_available(a) then table.insert(prefixes, a) end
    end
    -- Lab also has science_prefixes
    if specific.science_prefixes then
      for _, a in ipairs(specific.science_prefixes) do
        if is_available(a) then table.insert(prefixes, a) end
      end
    end
    for _, a in ipairs(specific.suffixes or {}) do
      if is_available(a) then table.insert(suffixes, a) end
    end
  end

  return { prefixes = prefixes, suffixes = suffixes }
end

function Affixes.get_armor_pool(force)
  local researched = {}
  if force then
    for tech_name, tech in pairs(force.technologies) do
      if tech.researched then researched[tech_name] = true end
    end
  end
  local function ok(a)
    return not a.requires_research or researched[a.requires_research]
  end
  local prefixes, suffixes = {}, {}
  for _, a in ipairs(Armor.prefixes) do if ok(a) then table.insert(prefixes, a) end end
  for _, a in ipairs(Armor.suffixes) do if ok(a) then table.insert(suffixes, a) end end
  return { prefixes = prefixes, suffixes = suffixes }
end

-- Lookup a single affix definition by ID across all tables
local _all_cache = nil
function Affixes.get_def(id)
  if not _all_cache then
    _all_cache = {}
    local all_sources = {
      Generic.prefixes, Generic.suffixes,
      Assembler.prefixes, Assembler.suffixes,
      Miner.prefixes, Miner.suffixes,
      Furnace.prefixes, Furnace.suffixes,
      Inserter.prefixes, Inserter.suffixes,
      Pole.prefixes, Pole.suffixes,
      Lab.prefixes, Lab.science_prefixes, Lab.suffixes,
      Armor.prefixes, Armor.suffixes,
    }
    for _, src in ipairs(all_sources) do
      if src then
        for _, a in ipairs(src) do _all_cache[a.id] = a end
      end
    end
  end
  return _all_cache[id]
end

return Affixes
