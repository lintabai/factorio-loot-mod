-- src/events.lua
-- Main event handler registration and routing.

local C               = require("src.constants")
local Rolling         = require("src.rolling")
local Applicator      = require("src.applicator")
local Serializer      = require("src.serializer")
local Storage         = require("src.storage")
local Naming          = require("src.naming")
local EntityDetection = require("src.entity_detection")
local GUI             = require("src.gui")
local Research        = require("src.research")
local Tick            = require("src.tick_handlers")
local AffixesMod      = require("src.affixes.init")

local Events = {}

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Read Lucky/Cursed bonus from player's equipped armor
local function get_player_lucky_bonus(player)
  if not player then return 0, 0 end
  local armor_inv = player.get_inventory(defines.inventory.character_armor)
  if not armor_inv then return 0, 0 end
  local lucky_total, cursed_total = 0, 0
  for i = 1, #armor_inv do
    local slot = armor_inv[i]
    if slot.valid_for_read then
      local ld = Serializer.read_tags(slot)
      if ld then
        for _, inst in ipairs(ld.prefixes or {}) do
          if inst.id == "lucky_armor"  then lucky_total  = lucky_total  + inst.value end
          if inst.id == "cursed_armor" then cursed_total = cursed_total + inst.value end
        end
        for _, inst in ipairs(ld.suffixes or {}) do
          if inst.id == "of_misfortune" then cursed_total = cursed_total + inst.value end
        end
      end
    end
  end
  return lucky_total, cursed_total
end

local function get_artificer_bonus(player)
  if not player then return 0 end
  local armor_inv = player.get_inventory(defines.inventory.character_armor)
  if not armor_inv then return 0 end
  for i = 1, #armor_inv do
    local slot = armor_inv[i]
    if slot.valid_for_read then
      local ld = Serializer.read_tags(slot)
      if ld then
        for _, inst in ipairs(ld.suffixes or {}) do
          if inst.id == "of_the_artificer" then return inst.value end
        end
      end
    end
  end
  return 0
end

-- Write loot data to an item stack + set label
local function tag_item_stack(stack, loot_data, proto_name)
  if not stack or not stack.valid_for_read then return end
  Serializer.write_tags(stack, loot_data)
  if loot_data.rarity ~= C.RARITY.NORMAL then
    local base = Naming.get_base_name(proto_name or stack.name)
    pcall(function()
      stack.label = Naming.build_name(base, loot_data.rarity,
        loot_data.prefixes, loot_data.suffixes)
    end)
  end
end

-- Persist entity loot data + apply effects to entity
local function finalize_entity(entity, loot_data)
  Storage.set_entity_data(entity.unit_number, loot_data)
  Applicator.apply(entity, loot_data)

  -- Register per-entity tick needs
  local function check_affix_list(list)
    for _, inst in ipairs(list or {}) do
      local def = AffixesMod.get_def(inst.id)
      if not def then goto continue end

      if def.effect == C.EFFECT.STALL then
        local data = Storage.get_entity_data(entity.unit_number)
        data.stall_affix = {
          entity_ref     = entity,
          duration       = inst.value,
          interval       = def.stall_interval and
            (def.stall_interval.min + math.random()*(def.stall_interval.max-def.stall_interval.min))
            or 60,
          stalled        = false,
          stall_end_tick = 0,
        }
        Storage.set_entity_data(entity.unit_number, data)
      end

      if def.effect == C.EFFECT.DUPLICATE_OUTPUT or def.effect == C.EFFECT.DELETE_OUTPUT then
        local data = Storage.get_entity_data(entity.unit_number)
        data.output_affix = data.output_affix or {}
        data.entity_ref   = entity
        table.insert(data.output_affix, inst)
        Storage.set_entity_data(entity.unit_number, data)
      end

      ::continue::
    end
  end
  check_affix_list(loot_data.prefixes)
  check_affix_list(loot_data.suffixes)
end

-- ── on_player_crafted_item ────────────────────────────────────────────────────

function Events.on_player_crafted_item(event)
  local stack  = event.item_stack
  local player = game.get_player(event.player_index)
  if not stack or not stack.valid_for_read then return end
  if Serializer.read_tags(stack) then return end

  local item_proto = prototypes.item[stack.name]
  if not item_proto then return end

  local entity_type, entity_name = EntityDetection.item_to_entity_info(item_proto)
  local is_armor = item_proto.type == "armor"
  if not entity_type and not is_armor then return end

  local lucky, cursed = get_player_lucky_bonus(player)
  local artificer = get_artificer_bonus(player)
  lucky = lucky + artificer
  local force = player and player.force or nil
  local loot_data

  if is_armor then
    local rarity   = Rolling.roll_rarity(force, lucky, cursed)
    local affixes  = Rolling.roll_armor_affixes(rarity, force)
    loot_data = {rarity=rarity, prefixes=affixes.prefixes, suffixes=affixes.suffixes, rerolls=0}
  else
    loot_data = Rolling.full_roll(entity_type, entity_name, force, lucky, cursed)
  end

  tag_item_stack(stack, loot_data, stack.name)
end

-- ── Entity built ──────────────────────────────────────────────────────────────
-- 2.0: on_built_entity passes event.consumed_items (LuaInventory), not event.stack.
-- on_robot_built_entity still passes event.stack (LuaItemStack).

local function find_loot_stack_in_consumed(consumed_items, target_item_name)
  if not consumed_items then return nil end
  for i = 1, #consumed_items do
    local s = consumed_items[i]
    if s.valid_for_read and s.name == target_item_name and Serializer.read_tags(s) then
      return s
    end
  end
  -- Fallback: any stack with loot tags
  for i = 1, #consumed_items do
    local s = consumed_items[i]
    if s.valid_for_read and Serializer.read_tags(s) then return s end
  end
  return nil
end

local function handle_entity_built(entity, source_stack)
  if not EntityDetection.is_rollable_entity(entity) then return end
  if entity.name == C.FORGE_ENTITY then return end

  local loot_data
  if source_stack and source_stack.valid_for_read then
    loot_data = Serializer.read_tags(source_stack)
  end

  if not loot_data then
    local force = entity.force
    loot_data = Rolling.full_roll(entity.type, entity.name, force, 0, 0)
  end

  finalize_entity(entity, loot_data)
end

function Events.on_built_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  -- 2.0: consumed_items is a LuaInventory
  local stack = find_loot_stack_in_consumed(event.consumed_items, entity.name)
  handle_entity_built(entity, stack)
end

function Events.on_robot_built_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  handle_entity_built(entity, event.stack)
end

function Events.script_raised_built(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  handle_entity_built(entity, nil)
end

-- ── Entity mined ──────────────────────────────────────────────────────────────
-- Transfer affix data from storage back into the mined item's tags
-- so the entity can be re-placed with the same affixes.

local function handle_entity_mined(entity, buffer)
  local data = Storage.get_entity_data(entity.unit_number)
  if not data then return end

  if buffer then
    for i = 1, #buffer do
      local slot = buffer[i]
      if slot.valid_for_read and not Serializer.read_tags(slot) then
        tag_item_stack(slot, data, slot.name)
        break
      end
    end
  end

  Storage.remove_entity_data(entity.unit_number)
end

function Events.on_player_mined_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if not EntityDetection.is_rollable_entity(entity) then return end
  handle_entity_mined(entity, event.buffer)
end

function Events.on_robot_mined_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if not EntityDetection.is_rollable_entity(entity) then return end
  handle_entity_mined(entity, event.buffer)
end

function Events.on_entity_died(event)
  local entity = event.entity
  if entity and entity.valid then
    Storage.remove_entity_data(entity.unit_number)
  end
end

-- ── Armor inventory changed ──────────────────────────────────────────────────
-- Movement/reach bonuses are applied at this point.
-- Track per-player applied bonuses to compute deltas safely.

local function compute_armor_bonuses(player)
  local move_total, reach_total = 0, 0
  local armor_inv = player.get_inventory(defines.inventory.character_armor)
  if not armor_inv then return move_total, reach_total end
  for i = 1, #armor_inv do
    local slot = armor_inv[i]
    if slot.valid_for_read then
      local ld = Serializer.read_tags(slot)
      if ld then
        for _, inst in ipairs(ld.prefixes or {}) do
          local def = AffixesMod.get_def(inst.id)
          if def and def.effect == C.EFFECT.MOVEMENT_BONUS then
            move_total = move_total + inst.value
          end
        end
        for _, inst in ipairs(ld.suffixes or {}) do
          local def = AffixesMod.get_def(inst.id)
          if def and def.effect == C.EFFECT.REACH_BONUS then
            reach_total = reach_total + inst.value
          end
        end
      end
    end
  end
  return move_total, reach_total
end

function Events.on_player_armor_inventory_changed(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character then return end

  storage.loot.player_armor = storage.loot.player_armor or {}
  local prev = storage.loot.player_armor[event.player_index] or {move=0, reach=0}
  local move_new, reach_new = compute_armor_bonuses(player)

  pcall(function()
    player.character.character_running_speed_modifier =
      (player.character.character_running_speed_modifier or 0) + (move_new - prev.move)
    player.character.character_reach_distance_bonus =
      (player.character.character_reach_distance_bonus or 0) + math.floor(reach_new - prev.reach)
  end)

  storage.loot.player_armor[event.player_index] = {move=move_new, reach=reach_new}
end

-- ── Registration ─────────────────────────────────────────────────────────────

function Events.register()
  script.on_event(defines.events.on_player_crafted_item,   Events.on_player_crafted_item)
  script.on_event(defines.events.on_built_entity,          Events.on_built_entity)
  script.on_event(defines.events.on_robot_built_entity,    Events.on_robot_built_entity)
  script.on_event(defines.events.script_raised_built,      Events.script_raised_built)
  script.on_event(defines.events.on_player_mined_entity,   Events.on_player_mined_entity)
  script.on_event(defines.events.on_robot_mined_entity,    Events.on_robot_mined_entity)
  script.on_event(defines.events.on_entity_died,           Events.on_entity_died)
  script.on_event(defines.events.on_gui_click,             GUI.on_gui_click)
  script.on_event(defines.events.on_gui_opened,            GUI.on_gui_opened)
  script.on_event(defines.events.on_gui_closed,            GUI.on_gui_closed)
  script.on_event(defines.events.on_research_finished,     Research.on_research_finished)
  script.on_event(defines.events.on_player_armor_inventory_changed,
    Events.on_player_armor_inventory_changed)

  Tick.register()
end

return Events
