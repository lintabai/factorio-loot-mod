-- src/tick_handlers.lua
-- on_nth_tick handlers for:
--   1. Resource-specific affix correction (every 6 ticks)
--   2. Stall affix processing (every 60 ticks)
--   3. Duplicate/delete output processing (every 6 ticks, after craft)

local C       = require("src.constants")
local Affixes = require("src.affixes.init")
local Storage = require("src.storage")

local Tick = {}

-- ── Resource-specific correction ─────────────────────────────────────────────
-- Tracks assemblers with resource-specific affixes.
-- When crafting_progress resets (craft completed), adjust input inventory.

function Tick.on_resource_tick()
  local tracked = Storage.get_resource_tick_entities()
  local to_remove = {}

  for unit_number, data in pairs(tracked) do
    local entity = data.entity
    if not entity or not entity.valid then
      table.insert(to_remove, unit_number)
    else
      local progress = entity.crafting_progress or 0
      local was_near_done = (data.last_progress or 0) > 0.85
      local just_reset    = progress < 0.10

      if was_near_done and just_reset then
        -- A craft just completed — run corrections
        Tick.apply_resource_corrections(entity, data.affixes)
      end
      data.last_progress = progress
    end
  end

  for _, un in ipairs(to_remove) do tracked[un] = nil end
end

function Tick.apply_resource_corrections(entity, affix_instances)
  if not entity.valid then return end
  local recipe = entity.get_recipe()
  if not recipe then return end

  local input_inv = entity.get_inventory(defines.inventory.assembling_machine_input)
  if not input_inv then return end

  for _, inst in ipairs(affix_instances or {}) do
    local def = Affixes.get_def(inst.id)
    if not def or def.effect ~= C.EFFECT.RESOURCE_SPECIFIC then goto continue end

    local resource = def.resource
    local sign = def.sign or 1 -- 1 = consume more, -1 = consume less (refund)
    local value = inst.value -- fraction

    -- Find ingredients matching the resource specifier
    for _, ingredient in ipairs(recipe.ingredients) do
      local matches = false
      if resource == ingredient.name then
        matches = true
      elseif resource == "__fluid__" and ingredient.type == "fluid" then
        matches = true
      elseif resource == "__plate__" and (
        ingredient.name:find("plate") or ingredient.name == "steel"
      ) then
        matches = true
      elseif resource == "__circuit__" and (
        ingredient.name:find("circuit") or ingredient.name:find("electronic")
      ) then
        matches = true
      end

      if matches then
        local base_count = ingredient.amount or 1
        local delta = math.floor(base_count * value + 0.5)
        if delta < 1 then delta = 1 end

        if sign < 0 then
          -- Refund: add items back to input
          -- Refund up to what was actually consumed (don't overflow)
          local stack = {name=ingredient.name, count=delta}
          if input_inv.can_insert(stack) then
            input_inv.insert(stack)
          end
        else
          -- Extra consumption: remove from input or output
          local output_inv = entity.get_inventory(defines.inventory.assembling_machine_output)
          if output_inv then
            -- Remove from output first, then from nearby or just leave (can't pull from nowhere)
            -- v0.1: attempt to remove from output as "waste"
            output_inv.remove({name=ingredient.name, count=delta})
          end
        end
      end
      ::continue::
    end
    ::continue::
  end
end

-- ── Stall affix processing ────────────────────────────────────────────────────
-- Checks entities with stall affixes and randomly pauses them.

function Tick.on_stall_tick(tick)
  local entities_data = storage.loot.entities
  for unit_number, data in pairs(entities_data) do
    if data.stall_affix then
      local sa = data.stall_affix
      -- Check if we should trigger a stall
      if not sa.stalled then
        -- Random chance to start stall (once per second check)
        local interval_ticks = (sa.interval or 60) * 60
        if tick % interval_ticks == 0 then
          if math.random() < 0.5 then -- 50% chance each interval to trigger
            sa.stalled = true
            sa.stall_end_tick = tick + math.floor(sa.duration * 60)
            -- Disable entity
            local entity = sa.entity_ref
            if entity and entity.valid then
              entity.active = false
            end
          end
        end
      else
        -- Check if stall is over
        if tick >= (sa.stall_end_tick or 0) then
          sa.stalled = false
          local entity = sa.entity_ref
          if entity and entity.valid then
            entity.active = true
          end
        end
      end
    end
  end
end

-- ── Duplicate/Delete output processing ───────────────────────────────────────
-- Runs after craft completion detection, similar to resource correction.
-- Checks assemblers with duplicate/delete output affixes.

function Tick.on_output_tick()
  local entities_data = storage.loot.entities
  for unit_number, data in pairs(entities_data) do
    if data.output_affix and data.entity_ref then
      local entity = data.entity_ref
      if not entity.valid then goto continue end

      local progress = entity.crafting_progress or 0
      local was_near_done = (data.last_output_progress or 0) > 0.85
      local just_reset = progress < 0.10

      if was_near_done and just_reset then
        Tick.apply_output_effects(entity, data.output_affix)
      end
      data.last_output_progress = progress
    end
    ::continue::
  end
end

function Tick.apply_output_effects(entity, output_affix_list)
  if not entity.valid then return end
  local output_inv = entity.get_inventory(defines.inventory.assembling_machine_output)
  if not output_inv then return end

  for _, affix_info in ipairs(output_affix_list) do
    local def = Affixes.get_def(affix_info.id)
    if not def then goto continue end

    -- Duplicate output
    if def.effect == C.EFFECT.DUPLICATE_OUTPUT and not def.is_echo
       and not def.is_random_quality and not def.is_research_bonus then
      if math.random() < affix_info.value then
        -- Find first non-empty output slot and duplicate one item
        for i = 1, #output_inv do
          local slot = output_inv[i]
          if slot.valid_for_read then
            output_inv.insert({name=slot.name, count=1, quality=slot.quality})
            break
          end
        end
      end
    end

    -- Delete output
    if def.effect == C.EFFECT.DELETE_OUTPUT and not def.is_input_loss
       and not def.is_quality_downgrade then
      if math.random() < affix_info.value then
        -- Remove one item from output
        for i = 1, #output_inv do
          local slot = output_inv[i]
          if slot.valid_for_read then
            output_inv.remove({name=slot.name, count=1})
            break
          end
        end
      end
    end

    ::continue::
  end
end

-- ── Register handlers ─────────────────────────────────────────────────────────

function Tick.register()
  -- Resource corrections: every 6 ticks (~10Hz)
  script.on_nth_tick(6, function() Tick.on_resource_tick() end)
  -- Output effects: every 6 ticks, offset by 3
  script.on_nth_tick(6, function() Tick.on_output_tick() end)
  -- Stall effects: every 60 ticks (1Hz)
  script.on_nth_tick(60, function(e) Tick.on_stall_tick(e.tick) end)
end

return Tick
