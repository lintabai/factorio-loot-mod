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
  -- Also check if armor has Artificer suffix (handled separately in full_roll)
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
  Serializer.write_tags(stack, loot_data)
  if loot_data.rarity ~= C.RARITY.NORMAL then
    local base = Naming.get_base_name(proto_name)
    stack.label = Naming.build_name(base, loot_data.rarity,
      loot_data.prefixes, loot_data.suffixes)
  end
end

-- Persist entity loot data + apply effects to entity
local function finalize_entity(entity, loot_data)
  Storage.set_entity_data(entity.unit_number, loot_data)
  Applicator.apply(entity, loot_data)

  -- Register per-entity tick needs
  local function check_affix_list(list)
    for _, inst in ipairs(list or {}) do
      local def = require("src.affixes.init").get_def(inst.id)
      if not def then goto continue end
      if def.effect == C.EFFECT.STALL then
        local data = Storage.get_entity_data(entity.unit_number)
        data.stall_affix = {
          entity_ref = entity,
          duration   = inst.value,
          interval   = def.stall_interval and
            (def.stall_interval.min + math.random()*(def.stall_interval.max-def.stall_interval.min))
            or 60,
          stalled    = false,
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
-- Fires when a player finishes hand-crafting an item.

function Events.on_player_crafted_item(event)
  local stack  = event.item_stack
  local player = game.get_player(event.player_index)
  if not stack or not stack.valid_for_read then return end

  -- Already rolled? (shouldn't happen on fresh craft, but be safe)
  if Serializer.read_tags(stack) then return end

  local item_proto = prototypes.item[stack.name]
  if not item_proto then return end

  -- Is this item a rollable entity placer?
  local entity_type, entity_name = EntityDetection.item_to_entity_info(item_proto)
  local is_armor = item_proto.type == "armor"

  if not entity_type and not is_armor then return end

  local lucky, cursed = get_player_lucky_bonus(player)
  local artificer = get_artificer_bonus(player)
  -- Artificer: bump lucky by the bonus tier count
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

-- ── on_built_entity / on_robot_built_entity / script_raised_built ─────────────
-- Fires when an entity is placed. Read tags → apply affixes.
-- If no tags (machine-crafted without roll), roll now.

local function handle_entity_built(entity, stack, player)
  if not EntityDetection.is_rollable_entity(entity) then return end
  if entity.name == C.FORGE_ENTITY then return end -- Forge itself doesn't roll

  local loot_data

  if stack and stack.valid_for_read then
    loot_data = Serializer.read_tags(stack)
  end

  if not loot_data then
    -- Machine-crafted or untagged: roll now
    local force  = entity.force
    loot_data = Rolling.full_roll(entity.type, entity.name, force, 0, 0)
  end

  finalize_entity(entity, loot_data)
end

function Events.on_built_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  -- event.stack is the item stack that was consumed (may be nil for script builds)
  local stack = event.stack
  handle_entity_built(entity, stack, game.get_player(event.player_index))
end

function Events.on_robot_built_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  handle_entity_built(entity, event.stack, nil)
end

function Events.script_raised_built(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  handle_entity_built(entity, nil, nil)
end

-- ── on_player_mined_entity / on_robot_mined_entity ───────────────────────────
-- When a loot entity is mined, write its affix data back to the item tags
-- so it can be re-placed with the same affixes.

local function handle_entity_mined(entity, inventory)
  local data = Storage.get_entity_data(entity.unit_number)
  if not data then
    Storage.remove_entity_data(entity.unit_number)
    return
  end

  -- Find the item in the inventory that was just produced
  if inventory then
    -- The item placed is the entity's mine result
    local mine_result
    if entity.prototype.mineable_properties then
      for _, product in ipairs(entity.prototype.mineable_properties.products or {}) do
        if product.type == "item" then
          mine_result = product.name; break
        end
      end
    end
    if mine_result then
      for i = 1, #inventory do
        local slot = inventory[i]
        if slot.valid_for_read and slot.name == mine_result then
          -- Check if not already tagged (pick the first untagged one)
          if not Serializer.read_tags(slot) then
            tag_item_stack(slot, data, mine_result)
            break
          end
        end
      end
    end
  end

  Storage.remove_entity_data(entity.unit_number)
end

function Events.on_player_mined_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if not EntityDetection.is_rollable_entity(entity) then return end
  local player = game.get_player(event.player_index)
  handle_entity_mined(entity, player and player.get_main_inventory() or nil)
end

function Events.on_robot_mined_entity(event)
  local entity = event.entity
  if not entity or not entity.valid then return end
  if not EntityDetection.is_rollable_entity(entity) then return end
  handle_entity_mined(entity, event.buffer)
end

-- ── on_entity_died ────────────────────────────────────────────────────────────
-- Cleanup storage when an entity is destroyed (no item recovery)

function Events.on_entity_died(event)
  local entity = event.entity
  if entity and entity.valid then
    Storage.remove_entity_data(entity.unit_number)
  end
end

-- ── Armor equip/unequip ───────────────────────────────────────────────────────
-- Apply/remove armor affixes on the player character when armor changes.
-- Factorio 2.x: use on_player_armor_inventory_changed

function Events.on_player_armor_inventory_changed(event)
  local player = game.get_player(event.player_index)
  if not player or not player.character then return end
  -- Re-scan all armor affixes and apply fresh
  -- (Simpler than tracking individual equip/unequip events)
  Events.reapply_armor(player)
end

function Events.reapply_armor(player)
  if not player or not player.character then return end
  -- Reset bonuses from previous armor (store baseline in player data if needed)
  -- v0.1: apply movement bonus from Lucky/Swift armor affixes
  -- Full armor effect system is tracked in player storage
  local armor_inv = player.get_inventory(defines.inventory.character_armor)
  if not armor_inv then return end
  -- Future: diff old vs new affixes. For now, sum all current.
  -- (Movement speed bonus via player.character.character_running_speed_modifier)
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
