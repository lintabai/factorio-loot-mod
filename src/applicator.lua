-- src/applicator.lua
-- Applies affix effects to placed LuaEntity instances.
-- Called once at placement; effects persist until entity is mined.

local C       = require("src.constants")
local Affixes = require("src.affixes.init")
local Storage = require("src.storage")
local Naming  = require("src.naming")

local Applicator = {}

-- ── Apply a single affix instance to an entity ───────────────────────────────

local function apply_one(entity, inst)
  local def = Affixes.get_def(inst.id)
  if not def then return end

  local effect = def.effect

  -- Direct LuaEntity property bonuses
  if effect == C.EFFECT.SPEED_BONUS then
    entity.speed_bonus = entity.speed_bonus + inst.value
  elseif effect == C.EFFECT.PRODUCTIVITY then
    entity.productivity_bonus = entity.productivity_bonus + inst.value
  elseif effect == C.EFFECT.CONSUMPTION then
    entity.consumption_bonus = entity.consumption_bonus + inst.value
  elseif effect == C.EFFECT.POLLUTION then
    entity.pollution_bonus = entity.pollution_bonus + inst.value
  end

  -- Linked effects (e.g. Overclocked: speed bonus + consumption penalty)
  if def.linked_effect then
    local le = def.linked_effect
    local le_val = le.value or (inst.value * (le.multiplier or 1))
    if le.effect == C.EFFECT.SPEED_BONUS then
      entity.speed_bonus = entity.speed_bonus + le_val
    elseif le.effect == C.EFFECT.CONSUMPTION then
      entity.consumption_bonus = entity.consumption_bonus + le_val
    elseif le.effect == C.EFFECT.POLLUTION then
      entity.pollution_bonus = entity.pollution_bonus + le_val
    end
  end

  -- Stack size override for inserters
  if def.is_stack_bonus and entity.type == "inserter" then
    local current = entity.inserter_stack_size_override or 1
    entity.inserter_stack_size_override = current + math.floor(inst.value)
  end

  -- Resource-specific affixes: register for on-tick processing
  if effect == C.EFFECT.RESOURCE_SPECIFIC then
    Storage.register_resource_tick(entity.unit_number, entity, {inst})
  end

  -- STALL: stored in entity data, processed by on_tick handler
  -- DUPLICATE_OUTPUT, DELETE_OUTPUT: processed by on_tick / on_entity_logistic_slot_changed
  -- SPAWN_BITERS: processed by on_research_finished handler
end

-- ── Main entry point ──────────────────────────────────────────────────────────

-- Apply all affixes in a loot_data table to an entity.
-- Sets entity.custom_name to the colored affix name.
function Applicator.apply(entity, loot_data)
  if not entity or not entity.valid then return end
  if loot_data.rarity == C.RARITY.NORMAL then
    -- Normal items: no affixes, no name change
    return
  end

  -- Apply all prefix + suffix bonuses
  for _, inst in ipairs(loot_data.prefixes or {}) do apply_one(entity, inst) end
  for _, inst in ipairs(loot_data.suffixes or {}) do apply_one(entity, inst) end

  -- Set colored name
  local base = Naming.get_base_name(entity.name)
  entity.custom_name = Naming.build_name(base, loot_data.rarity,
    loot_data.prefixes, loot_data.suffixes)
end

-- Undo all applied bonuses (called before re-applying after reroll, or on mine)
-- NOTE: We store a snapshot of what was applied so we can subtract it exactly.
function Applicator.unapply(entity, loot_data)
  if not entity or not entity.valid then return end
  if loot_data.rarity == C.RARITY.NORMAL then return end

  local function undo_one(inst)
    local def = Affixes.get_def(inst.id)
    if not def then return end
    local effect = def.effect
    if effect == C.EFFECT.SPEED_BONUS then
      entity.speed_bonus = entity.speed_bonus - inst.value
    elseif effect == C.EFFECT.PRODUCTIVITY then
      entity.productivity_bonus = entity.productivity_bonus - inst.value
    elseif effect == C.EFFECT.CONSUMPTION then
      entity.consumption_bonus = entity.consumption_bonus - inst.value
    elseif effect == C.EFFECT.POLLUTION then
      entity.pollution_bonus = entity.pollution_bonus - inst.value
    end
    if def.linked_effect then
      local le = def.linked_effect
      local le_val = le.value or (inst.value * (le.multiplier or 1))
      if le.effect == C.EFFECT.SPEED_BONUS then
        entity.speed_bonus = entity.speed_bonus - le_val
      elseif le.effect == C.EFFECT.CONSUMPTION then
        entity.consumption_bonus = entity.consumption_bonus - le_val
      elseif le.effect == C.EFFECT.POLLUTION then
        entity.pollution_bonus = entity.pollution_bonus - le_val
      end
    end
    if def.is_stack_bonus and entity.type == "inserter" then
      local current = entity.inserter_stack_size_override or 1
      entity.inserter_stack_size_override = math.max(1, current - math.floor(inst.value))
    end
  end

  for _, inst in ipairs(loot_data.prefixes or {}) do undo_one(inst) end
  for _, inst in ipairs(loot_data.suffixes or {}) do undo_one(inst) end
  entity.custom_name = nil
end

return Applicator
