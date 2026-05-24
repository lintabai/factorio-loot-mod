-- src/serializer.lua
-- Serialize/deserialize affix data to/from item tag strings.
-- LuaItemStack.tags values must be AnyBasic (string/number/bool/nil).
-- We store affix data as a JSON string under a single tag key.

local C = require("src.constants")
local Serializer = {}

function Serializer.pack(loot_data)
  -- loot_data = { rarity, prefixes=[{id,value,tier}], suffixes=[{id,value,tier}], rerolls }
  return helpers.table_to_json(loot_data)
end

function Serializer.unpack(json_str)
  if not json_str or json_str == "" then return nil end
  local ok, result = pcall(helpers.json_to_table, json_str)
  if not ok then return nil end
  return result
end

-- Write loot data into an ItemStack's tags
function Serializer.write_tags(stack, loot_data)
  if not stack or not stack.valid_for_read then return end
  local tags = stack.tags or {}
  tags[C.TAG.ROLLED]  = true
  tags[C.TAG.RARITY]  = loot_data.rarity
  tags[C.TAG.AFFIXES] = Serializer.pack({
    prefixes = loot_data.prefixes,
    suffixes = loot_data.suffixes,
  })
  tags[C.TAG.REROLLS] = loot_data.rerolls or 0
  stack.tags = tags
end

-- Read loot data from an ItemStack's tags
-- Returns nil if not a loot item
function Serializer.read_tags(stack)
  if not stack or not stack.valid_for_read then return nil end
  local tags = stack.tags
  if not tags or not tags[C.TAG.ROLLED] then return nil end
  local affix_data = Serializer.unpack(tags[C.TAG.AFFIXES])
  if not affix_data then return nil end
  return {
    rarity   = tags[C.TAG.RARITY] or C.RARITY.NORMAL,
    prefixes = affix_data.prefixes or {},
    suffixes = affix_data.suffixes or {},
    rerolls  = tags[C.TAG.REROLLS] or 0,
  }
end

return Serializer
