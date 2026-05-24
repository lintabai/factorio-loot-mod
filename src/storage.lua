-- src/storage.lua
-- All persistent state lives in `storage` (Factorio 2.x renamed `global`).
-- Never store LuaEntity directly outside short-lived refs — always unit_number for keys.
-- Granular init pattern so mod updates don't leave new fields nil.

local Storage = {}

function Storage.init()
  storage.loot = storage.loot or {}
  storage.loot.entities               = storage.loot.entities               or {}
  storage.loot.resource_tick_entities = storage.loot.resource_tick_entities or {}
  storage.loot.forge_gui              = storage.loot.forge_gui              or {}
  storage.loot.player_armor           = storage.loot.player_armor           or {}
end

function Storage.get_entity_data(unit_number)
  return storage.loot.entities[unit_number]
end

function Storage.set_entity_data(unit_number, data)
  storage.loot.entities[unit_number] = data
end

function Storage.remove_entity_data(unit_number)
  storage.loot.entities[unit_number]               = nil
  storage.loot.resource_tick_entities[unit_number] = nil
end

function Storage.register_resource_tick(unit_number, entity, affix_data)
  storage.loot.resource_tick_entities[unit_number] = {
    entity        = entity,
    affixes       = affix_data,
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
