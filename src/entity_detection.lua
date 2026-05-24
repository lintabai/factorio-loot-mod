-- src/entity_detection.lua
-- Determines whether an entity/item is rollable and maps it to an affix category.

local C = require("src.constants")
local EntityDetection = {}

-- Returns true if this entity type can receive affixes
function EntityDetection.is_rollable_entity(entity)
  if not entity or not entity.valid then return false end
  return C.ROLLABLE_ENTITY_TYPES[entity.type] == true
end

-- Returns true if this item places a rollable entity or is rollable armor
function EntityDetection.is_rollable_item(item_prototype)
  if not item_prototype then return false end

  -- Armor
  if C.ROLLABLE_ARMOR_TYPES[item_prototype.type] then return true end

  -- Entity-placing items: check what entity the item places
  local place_result = item_prototype.place_result
  if place_result and C.ROLLABLE_ENTITY_TYPES[place_result.type] then
    return true
  end

  return false
end

-- Returns the entity type + name for a placed item (for rolling purposes)
function EntityDetection.item_to_entity_info(item_prototype)
  if not item_prototype then return nil, nil end
  local place_result = item_prototype.place_result
  if place_result then
    return place_result.type, place_result.name
  end
  return nil, nil
end

-- Check if the forge entity name matches our forge
function EntityDetection.is_forge(entity)
  return entity and entity.valid and entity.name == C.FORGE_ENTITY
end

return EntityDetection
