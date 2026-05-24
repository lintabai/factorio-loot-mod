-- src/applicator.lua
-- Applies affix effects to placed LuaEntity instances.
-- Called once at placement; effects persist until entity is mined.

local C       = require("src.constants")
local Affixes = require("src.affixes.init")
local Storage = require("src.storage")
local Naming  = require("src.naming")

local Applicator = {}

-- Types that support speed_bonus, productivity_bonus, consumption_bonus, pollution_bonus
local SUPPORTS_BONUSES = {
  ["assembling-machine"] = true,
  ["furnace"]            = true,
  ["mining-drill"]       = true,
  ["lab"]                = true,
  ["rocket-silo"]        = true,
}

local function set_bonus(entity, prop, delta)
  if not SUPPORTS_BONUSES[entity.type] then return end
  -- pcall to defensively guard against modded entity quirks
  pcall(function() entity[prop] = (entity[prop] or 0) + delta end)
end

local function apply_one(entity, inst)
  local def = Affixes.get_def(inst.id)
  if not def then return end
  local effect = def.effect

  if     effect == C.EFFECT.SPEED_BONUS  then set_bonus(entity, "speed_bonus",        inst.value)
  elseif effect == C.EFFECT.PRODUCTIVITY then set_bonus(entity, "productivity_bonus", inst.value)
  elseif effect == C.EFFECT.CONSUMPTION  then set_bonus(entity, "consumption_bonus",  inst.value)
  elseif effect == C.EFFECT.POLLUTION    then set_bonus(entity, "pollution_bonus",    inst.value)
  end

  if def.linked_effect then
    local le = def.linked_effect
    local le_val = le.value or (inst.value * (le.multiplier or 1))
    if     le.effect == C.EFFECT.SPEED_BONUS  then set_bonus(entity, "speed_bonus",        le_val)
    elseif le.effect == C.EFFECT.CONSUMPTION  then set_bonus(entity, "consumption_bonus",  le_val)
    elseif le.effect == C.EFFECT.POLLUTION    then set_bonus(entity, "pollution_bonus",    le_val)
    elseif le.effect == C.EFFECT.PRODUCTIVITY then set_bonus(entity, "productivity_bonus", le_val)
    end
  end

  -- Inserter stack size: only on inserters
  if def.is_stack_bonus and entity.type == "inserter" then
    pcall(function()
      local current = entity.inserter_stack_size_override or 0
      entity.inserter_stack_size_override = current + math.floor(inst.value)
    end)
  end

  -- Resource-specific: register for tick processing
  if effect == C.EFFECT.RESOURCE_SPECIFIC then
    Storage.register_resource_tick(entity.unit_number, entity, {inst})
  end
end

function Applicator.apply(entity, loot_data)
  if not entity or not entity.valid then return end
  if loot_data.rarity == C.RARITY.NORMAL then return end

  for _, inst in ipairs(loot_data.prefixes or {}) do apply_one(entity, inst) end
  for _, inst in ipairs(loot_data.suffixes or {}) do apply_one(entity, inst) end

  -- Colored entity name (only for entities that support backer_name/custom_name)
  pcall(function()
    local base = Naming.get_base_name(entity.name)
    entity.custom_name = Naming.build_name(base, loot_data.rarity,
      loot_data.prefixes, loot_data.suffixes)
  end)
end

function Applicator.unapply(entity, loot_data)
  if not entity or not entity.valid then return end
  if loot_data.rarity == C.RARITY.NORMAL then return end

  local function undo_one(inst)
    local def = Affixes.get_def(inst.id)
    if not def then return end
    local effect = def.effect
    if     effect == C.EFFECT.SPEED_BONUS  then set_bonus(entity, "speed_bonus",        -inst.value)
    elseif effect == C.EFFECT.PRODUCTIVITY then set_bonus(entity, "productivity_bonus", -inst.value)
    elseif effect == C.EFFECT.CONSUMPTION  then set_bonus(entity, "consumption_bonus",  -inst.value)
    elseif effect == C.EFFECT.POLLUTION    then set_bonus(entity, "pollution_bonus",    -inst.value)
    end
    if def.linked_effect then
      local le = def.linked_effect
      local le_val = le.value or (inst.value * (le.multiplier or 1))
      if     le.effect == C.EFFECT.SPEED_BONUS  then set_bonus(entity, "speed_bonus",        -le_val)
      elseif le.effect == C.EFFECT.CONSUMPTION  then set_bonus(entity, "consumption_bonus",  -le_val)
      elseif le.effect == C.EFFECT.POLLUTION    then set_bonus(entity, "pollution_bonus",    -le_val)
      end
    end
    if def.is_stack_bonus and entity.type == "inserter" then
      pcall(function()
        local current = entity.inserter_stack_size_override or 0
        entity.inserter_stack_size_override = math.max(0, current - math.floor(inst.value))
      end)
    end
  end
  for _, inst in ipairs(loot_data.prefixes or {}) do undo_one(inst) end
  for _, inst in ipairs(loot_data.suffixes or {}) do undo_one(inst) end
  pcall(function() entity.custom_name = nil end)
end

return Applicator
