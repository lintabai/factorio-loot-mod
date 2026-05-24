-- src/rolling.lua
-- Handles rarity rolling and affix selection.

local C       = require("src.constants")
local Affixes = require("src.affixes.init")

local Rolling = {}

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function weighted_pick(pool)
  local total = 0
  for _, item in ipairs(pool) do total = total + (item.weight or 1) end
  local r = math.random() * total
  local cum = 0
  for _, item in ipairs(pool) do
    cum = cum + (item.weight or 1)
    if r <= cum then return item end
  end
  return pool[#pool]
end

local function roll_value(tier)
  if tier.min == tier.max then return tier.min end
  -- Round integer tiers (stack bonuses, etc.)
  local v = tier.min + math.random() * (tier.max - tier.min)
  if math.floor(tier.min) == tier.min and math.floor(tier.max) == tier.max then
    return math.floor(v + 0.5)
  end
  -- 2 decimal places for floats
  return math.floor(v * 100 + 0.5) / 100
end

-- Returns the highest rarity the force has researched, as index into RARITY_ORDER
local function max_rarity_index(force)
  local max_idx = 1 -- always at least normal
  for idx, rarity in ipairs(C.RARITY_ORDER) do
    local gate = C.RARITY_RESEARCH_GATE[rarity]
    if gate == nil or (force and force.technologies[gate] and force.technologies[gate].researched) then
      max_idx = idx
    end
  end
  return max_idx
end

-- ── Core rarity roll ──────────────────────────────────────────────────────────

-- Rolls a rarity, capped to what the force has researched.
-- lucky_rolls: roll N+1 times, return best (Lucky affix)
-- cursed_rolls: roll N+1 times, return worst (Cursed affix)
function Rolling.roll_rarity(force, lucky_rolls, cursed_rolls)
  local max_idx = max_rarity_index(force)

  -- Build capped weight table
  local pool = {}
  local total = 0
  for idx, rarity in ipairs(C.RARITY_ORDER) do
    if idx <= max_idx then
      local w = C.RARITY_WEIGHTS[rarity]
      table.insert(pool, { rarity = rarity, idx = idx, weight = w })
      total = total + w
    end
  end

  local function single_roll()
    local r = math.random() * total
    local cum = 0
    for _, entry in ipairs(pool) do
      cum = cum + entry.weight
      if r <= cum then return entry end
    end
    return pool[#pool]
  end

  -- Lucky: roll (1 + lucky_rolls) times, take best
  local rolls = 1 + (lucky_rolls or 0) + (cursed_rolls or 0)
  local results = {}
  for _ = 1, math.max(1, rolls) do
    table.insert(results, single_roll())
  end

  if (lucky_rolls or 0) > 0 then
    -- Take highest index result
    local best = results[1]
    for _, r in ipairs(results) do
      if r.idx > best.idx then best = r end
    end
    return best.rarity
  elseif (cursed_rolls or 0) > 0 then
    -- Take lowest index result
    local worst = results[1]
    for _, r in ipairs(results) do
      if r.idx < worst.idx then worst = r end
    end
    return worst.rarity
  end

  return results[1].rarity
end

-- ── Affix rolling ─────────────────────────────────────────────────────────────

local function roll_affix_list(pool, count)
  if count == 0 or #pool == 0 then return {} end
  local chosen = {}
  local used_ids = {}
  local attempts = 0

  while #chosen < count and attempts < 50 do
    attempts = attempts + 1
    if #pool == 0 then break end
    local def = weighted_pick(pool)
    if not used_ids[def.id] then
      used_ids[def.id] = true
      local tier_entry = weighted_pick(def.tiers)
      local value = roll_value(tier_entry)
      table.insert(chosen, {
        id    = def.id,
        value = value,
        -- Store tier index for display / Blessed orb reroll
        tier  = (function()
          for i, t in ipairs(def.tiers) do
            if t == tier_entry then return i end
          end
          return 1
        end)(),
      })
    end
  end
  return chosen
end

-- Roll affixes for a given rarity + entity info
function Rolling.roll_affixes(rarity, entity_type, entity_name, force)
  local slots  = C.RARITY_SLOTS[rarity]
  local pool   = Affixes.get_pool(entity_type, entity_name, force)

  return {
    prefixes = roll_affix_list(pool.prefixes, slots.prefix),
    suffixes = roll_affix_list(pool.suffixes, slots.suffix),
  }
end

-- Roll affixes for armor
function Rolling.roll_armor_affixes(rarity, force)
  local slots = C.RARITY_SLOTS[rarity]
  local pool  = Affixes.get_armor_pool(force)
  return {
    prefixes = roll_affix_list(pool.prefixes, slots.prefix),
    suffixes = roll_affix_list(pool.suffixes, slots.suffix),
  }
end

-- Reroll values only (Blessed Orb) — keep which affixes, re-roll their values
function Rolling.reroll_values(affix_data)
  local function reroll_list(list)
    local result = {}
    for _, inst in ipairs(list) do
      local def = require("src.affixes.init").get_def(inst.id)
      if def then
        local tier_entry = def.tiers[inst.tier] or def.tiers[1]
        table.insert(result, {
          id    = inst.id,
          tier  = inst.tier,
          value = roll_value(tier_entry),
        })
      else
        table.insert(result, inst)
      end
    end
    return result
  end
  return {
    prefixes = reroll_list(affix_data.prefixes),
    suffixes = reroll_list(affix_data.suffixes),
  }
end

-- Full roll: rarity + affixes in one call
-- Returns { rarity, prefixes, suffixes }
function Rolling.full_roll(entity_type, entity_name, force, lucky_bonus, cursed_bonus)
  local rarity  = Rolling.roll_rarity(force, lucky_bonus, cursed_bonus)
  local affixes = Rolling.roll_affixes(rarity, entity_type, entity_name, force)
  return {
    rarity   = rarity,
    prefixes = affixes.prefixes,
    suffixes = affixes.suffixes,
    rerolls  = 0,
  }
end

return Rolling
