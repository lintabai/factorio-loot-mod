-- src/tick_handlers.lua
-- on_nth_tick handlers, combined into single registrations per interval
-- (script.on_nth_tick(N, ...) only allows ONE handler per N).

local C       = require("src.constants")
local Affixes = require("src.affixes.init")
local Storage = require("src.storage")

local Tick = {}

-- Entities that have crafting_progress
local HAS_CRAFTING_PROGRESS = {
  ["assembling-machine"] = true,
  ["furnace"]            = true,
  ["rocket-silo"]        = true,
}

-- ── Resource-specific correction ─────────────────────────────────────────────

function Tick.on_resource_tick()
  local tracked = Storage.get_resource_tick_entities()
  local to_remove = {}

  for unit_number, data in pairs(tracked) do
    local entity = data.entity
    if not entity or not entity.valid then
      table.insert(to_remove, unit_number)
    elseif HAS_CRAFTING_PROGRESS[entity.type] then
      local progress = entity.crafting_progress or 0
      local was_near_done = (data.last_progress or 0) > 0.85
      local just_reset    = progress < 0.10
      if was_near_done and just_reset then
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

  local input_inv  = entity.get_inventory(defines.inventory.assembling_machine_input)
  local output_inv = entity.get_inventory(defines.inventory.assembling_machine_output)
  if not input_inv then return end

  for _, inst in ipairs(affix_instances or {}) do
    local def = Affixes.get_def(inst.id)
    if def and def.effect == C.EFFECT.RESOURCE_SPECIFIC then
      local resource = def.resource
      local sign     = def.sign or 1
      local value    = inst.value

      for _, ingredient in ipairs(recipe.ingredients) do
        local matches = false
        if resource == ingredient.name then
          matches = true
        elseif resource == "__fluid__" and ingredient.type == "fluid" then
          matches = true
        elseif resource == "__plate__" and ingredient.name:find("plate") then
          matches = true
        elseif resource == "__circuit__" and (
            ingredient.name:find("circuit") or ingredient.name == "processing-unit"
        ) then
          matches = true
        end

        if matches and ingredient.type == "item" then
          local base_count = ingredient.amount or 1
          local delta = math.max(1, math.floor(base_count * value + 0.5))

          if sign < 0 then
            -- Refund items to input
            if input_inv.can_insert({name=ingredient.name, count=delta}) then
              input_inv.insert({name=ingredient.name, count=delta})
            end
          else
            -- Extra cost: remove from output as "waste"
            if output_inv then
              output_inv.remove({name=ingredient.name, count=delta})
            end
          end
        end
      end
    end
  end
end

-- ── Stall affix processing ────────────────────────────────────────────────────

function Tick.on_stall_tick(tick)
  if not storage.loot or not storage.loot.entities then return end
  for unit_number, data in pairs(storage.loot.entities) do
    local sa = data.stall_affix
    if sa then
      local entity = sa.entity_ref
      if not entity or not entity.valid then
        data.stall_affix = nil
      else
        if not sa.stalled then
          local interval_ticks = math.floor((sa.interval or 60) * 60)
          if interval_ticks > 0 and tick % interval_ticks == 0 then
            if math.random() < 0.5 then
              sa.stalled = true
              sa.stall_end_tick = tick + math.floor(sa.duration * 60)
              pcall(function() entity.active = false end)
            end
          end
        else
          if tick >= (sa.stall_end_tick or 0) then
            sa.stalled = false
            pcall(function() entity.active = true end)
          end
        end
      end
    end
  end
end

-- ── Duplicate/Delete output processing ───────────────────────────────────────

function Tick.on_output_tick()
  if not storage.loot or not storage.loot.entities then return end
  for unit_number, data in pairs(storage.loot.entities) do
    if data.output_affix and data.entity_ref then
      local entity = data.entity_ref
      if not entity or not entity.valid then
        data.output_affix = nil
        data.entity_ref   = nil
      elseif HAS_CRAFTING_PROGRESS[entity.type] then
        local progress = entity.crafting_progress or 0
        local was_near_done = (data.last_output_progress or 0) > 0.85
        local just_reset    = progress < 0.10
        if was_near_done and just_reset then
          Tick.apply_output_effects(entity, data.output_affix)
        end
        data.last_output_progress = progress
      end
    end
  end
end

function Tick.apply_output_effects(entity, output_affix_list)
  if not entity.valid then return end
  local output_inv
  if entity.type == "furnace" then
    output_inv = entity.get_output_inventory()
  else
    output_inv = entity.get_inventory(defines.inventory.assembling_machine_output)
  end
  if not output_inv then return end

  for _, affix_info in ipairs(output_affix_list) do
    local def = Affixes.get_def(affix_info.id)
    if def then
      if def.effect == C.EFFECT.DUPLICATE_OUTPUT
         and not def.is_echo and not def.is_random_quality
         and not def.is_research_bonus then
        if math.random() < affix_info.value then
          for i = 1, #output_inv do
            local slot = output_inv[i]
            if slot.valid_for_read then
              output_inv.insert({name=slot.name, count=1, quality=slot.quality})
              break
            end
          end
        end
      elseif def.effect == C.EFFECT.DELETE_OUTPUT
             and not def.is_input_loss
             and not def.is_quality_downgrade then
        if math.random() < affix_info.value then
          for i = 1, #output_inv do
            local slot = output_inv[i]
            if slot.valid_for_read then
              output_inv.remove({name=slot.name, count=1})
              break
            end
          end
        end
      end
    end
  end
end

-- ── Register (combine multiple handlers into one per interval) ───────────────

function Tick.register()
  script.on_nth_tick(6, function()
    Tick.on_resource_tick()
    Tick.on_output_tick()
  end)
  script.on_nth_tick(60, function(e)
    Tick.on_stall_tick(e.tick)
  end)
end

return Tick
