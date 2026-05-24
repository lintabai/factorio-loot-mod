-- src/storage.lua
-- All persistent state lives in `storage` (Factorio 2.x renamed `global` to `storage`).
-- Never store LuaEntity directly — always unit_number.

local Storage = {}

function Storage.init()
  storage.loot = storage.loot or {
    -- [unit_number] = { rarity, prefixes, suffixes, rerolls }
    entities = {},
    -- [unit_number] = { entity ref (refreshed), affixes snapshot }
    -- assemblers with resource-specific affixes that need on-tick processing
    resource_tick_entities = {},
    -- [unit_number] = { entity ref, last_crafting_progress }
    craft_progress_tracker = {},
    -- [player_index] = { forge_entity_unit_number, frame }
    forge_gui = {},
  }
end

function Storage.get_entity_data(unit_number)
  return storage.loot.entities[unit_number]
end

function Storage.set_entity_data(unit_number, data)
  storage.loot.entities[unit_number] = data
end

function Storage.remove_entity_data(unit_number)
  storage.loot.entities[unit_number] = nil
  storage.loot.resource_tick_entities[unit_number] = nil
  storage.loot.craft_progress_tracker[unit_number] = nil
end

function Storage.register_resource_tick(unit_number, entity, affix_data)
  storage.loot.resource_tick_entities[unit_number] = {
    entity = entity,
    affixes = affix_data,
    last_progress = 0,
  }
end

function Storage.get_resource_tick_entities()
  return storage.loot.resource_tick_entities
end

function Storage.set_forge_gui(player_index, data)
  storage.loot.forge_gui[player_index] = data
end

function Storage.get_forge_gui(player_index)
  return storage.loot.forge_gui[player_index]
end

function Storage.clear_forge_gui(player_index)
  storage.loot.forge_gui[player_index] = nil
end

return Storage
