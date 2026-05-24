-- src/forge.lua
-- Tinkerer's Forge reroll logic.
-- The Forge is a container entity with 2 inventory slots (item + orb).
-- GUI is opened via on_gui_opened; Apply button triggers process_forge().

local C          = require("src.constants")
local Rolling    = require("src.rolling")
local Applicator = require("src.applicator")
local Serializer = require("src.serializer")
local Storage    = require("src.storage")
local Naming     = require("src.naming")

local Forge = {}

-- ── Orb action definitions ────────────────────────────────────────────────────

-- Returns { ok=bool, error=string } after validation
-- Returns { ok=true, result=loot_data } on success
function Forge.apply_orb(orb_name, loot_data, entity_type, entity_name, force)
  local r = loot_data.rarity
  local C_ORB = C.ORB

  -- Transmutation: Normal → Magic
  if orb_name == C_ORB.TRANSMUTATION then
    if r ~= C.RARITY.NORMAL then
      return {ok=false, error="Orb of Transmutation requires a Normal item"}
    end
    local new_affixes = Rolling.roll_affixes(C.RARITY.MAGIC, entity_type, entity_name, force)
    return {ok=true, result={
      rarity=C.RARITY.MAGIC, prefixes=new_affixes.prefixes,
      suffixes=new_affixes.suffixes, rerolls=0
    }}

  -- Alteration: reroll all affixes on Magic
  elseif orb_name == C_ORB.ALTERATION then
    if r ~= C.RARITY.MAGIC then
      return {ok=false, error="Orb of Alteration requires a Magic item"}
    end
    local new_affixes = Rolling.roll_affixes(C.RARITY.MAGIC, entity_type, entity_name, force)
    return {ok=true, result={
      rarity=C.RARITY.MAGIC, prefixes=new_affixes.prefixes,
      suffixes=new_affixes.suffixes, rerolls=(loot_data.rerolls or 0)+1
    }}

  -- Alchemy: Normal → Rare
  elseif orb_name == C_ORB.ALCHEMY then
    if r ~= C.RARITY.NORMAL then
      return {ok=false, error="Orb of Alchemy requires a Normal item"}
    end
    local new_affixes = Rolling.roll_affixes(C.RARITY.RARE, entity_type, entity_name, force)
    return {ok=true, result={
      rarity=C.RARITY.RARE, prefixes=new_affixes.prefixes,
      suffixes=new_affixes.suffixes, rerolls=0
    }}

  -- Chaos: reroll all affixes on Rare
  elseif orb_name == C_ORB.CHAOS then
    if r ~= C.RARITY.RARE then
      return {ok=false, error="Orb of Chaos requires a Rare item"}
    end
    local new_affixes = Rolling.roll_affixes(C.RARITY.RARE, entity_type, entity_name, force)
    return {ok=true, result={
      rarity=C.RARITY.RARE, prefixes=new_affixes.prefixes,
      suffixes=new_affixes.suffixes, rerolls=(loot_data.rerolls or 0)+1
    }}

  -- Augmentation: add 1 affix if a slot is open
  elseif orb_name == C_ORB.AUGMENTATION then
    local slots = C.RARITY_SLOTS[r]
    local pfx_open = slots.prefix - #loot_data.prefixes
    local sfx_open = slots.suffix - #loot_data.suffixes
    if pfx_open <= 0 and sfx_open <= 0 then
      return {ok=false, error="No open affix slots on this item"}
    end
    local pool = require("src.affixes.init").get_pool(entity_type, entity_name, force)
    local new_pfx = {table.unpack(loot_data.prefixes)}
    local new_sfx = {table.unpack(loot_data.suffixes)}
    if pfx_open > 0 and #pool.prefixes > 0 then
      local def = pool.prefixes[math.random(#pool.prefixes)]
      local tier = def.tiers[math.random(#def.tiers)]
      table.insert(new_pfx, {id=def.id, value=tier.min + math.random()*(tier.max-tier.min), tier=1})
    elseif sfx_open > 0 and #pool.suffixes > 0 then
      local def = pool.suffixes[math.random(#pool.suffixes)]
      local tier = def.tiers[math.random(#def.tiers)]
      table.insert(new_sfx, {id=def.id, value=tier.min + math.random()*(tier.max-tier.min), tier=1})
    end
    return {ok=true, result={
      rarity=r, prefixes=new_pfx, suffixes=new_sfx,
      rerolls=(loot_data.rerolls or 0)+1
    }}

  -- Annulment: remove 1 random affix
  elseif orb_name == C_ORB.ANNULMENT then
    local all = {}
    for _, a in ipairs(loot_data.prefixes) do table.insert(all, {type="p",a=a}) end
    for _, a in ipairs(loot_data.suffixes) do table.insert(all, {type="s",a=a}) end
    if #all == 0 then
      return {ok=false, error="Item has no affixes to remove"}
    end
    local remove_idx = math.random(#all)
    local remove = all[remove_idx]
    local new_pfx, new_sfx = {}, {}
    for _, a in ipairs(loot_data.prefixes) do
      if not (remove.type=="p" and a.id==remove.a.id) then table.insert(new_pfx,a) end
    end
    for _, a in ipairs(loot_data.suffixes) do
      if not (remove.type=="s" and a.id==remove.a.id) then table.insert(new_sfx,a) end
    end
    return {ok=true, result={
      rarity=r, prefixes=new_pfx, suffixes=new_sfx,
      rerolls=(loot_data.rerolls or 0)+1
    }}

  -- Scouring: strip to Normal
  elseif orb_name == C_ORB.SCOURING then
    if r == C.RARITY.NORMAL then
      return {ok=false, error="Item is already Normal"}
    end
    return {ok=true, result={rarity=C.RARITY.NORMAL, prefixes={}, suffixes={}, rerolls=0}}

  -- Exaltation: add 1 affix to Rare with open slot
  elseif orb_name == C_ORB.EXALTATION then
    if r ~= C.RARITY.RARE and r ~= C.RARITY.EPIC and r ~= C.RARITY.LEGENDARY then
      return {ok=false, error="Orb of Exaltation requires Rare or higher"}
    end
    local slots = C.RARITY_SLOTS[r]
    local pfx_open = slots.prefix - #loot_data.prefixes
    local sfx_open = slots.suffix - #loot_data.suffixes
    if pfx_open <= 0 and sfx_open <= 0 then
      return {ok=false, error="No open affix slots"}
    end
    -- Reuse AUGMENTATION logic
    return Forge.apply_orb(C_ORB.AUGMENTATION, loot_data, entity_type, entity_name, force)

  -- Blessed: reroll values only
  elseif orb_name == C_ORB.BLESSED then
    if r == C.RARITY.NORMAL then
      return {ok=false, error="Normal items have no affix values to reroll"}
    end
    local new_affixes = Rolling.reroll_values({
      prefixes=loot_data.prefixes, suffixes=loot_data.suffixes
    })
    return {ok=true, result={
      rarity=r, prefixes=new_affixes.prefixes, suffixes=new_affixes.suffixes,
      rerolls=(loot_data.rerolls or 0)+1
    }}
  end

  return {ok=false, error="Unknown orb"}
end

-- ── Destruction roll ──────────────────────────────────────────────────────────

function Forge.should_destroy(rarity)
  local chance = C.REROLL_DESTRUCTION_CHANCE[rarity] or 0
  if chance == 0 then return false end
  return math.random() < chance
end

-- ── Process the forge (called on Apply button click) ─────────────────────────

-- forge_entity: the Forge LuaEntity (container)
-- player: the LuaPlayer who clicked Apply
-- Returns { ok, message, destroyed }
function Forge.process(forge_entity, player)
  if not forge_entity.valid then
    return {ok=false, message="Forge is no longer valid"}
  end

  local inv = forge_entity.get_inventory(defines.inventory.chest)
  if not inv then return {ok=false, message="Forge inventory error"} end

  -- Slot 1: entity item, Slot 2: orb
  local item_slot = inv[1]
  local orb_slot  = inv[2]

  if not item_slot.valid_for_read then
    return {ok=false, message="Put an item in slot 1"}
  end
  if not orb_slot.valid_for_read then
    return {ok=false, message="Put a currency orb in slot 2"}
  end

  -- Validate orb
  local orb_name = orb_slot.name
  local is_valid_orb = false
  for _, o in ipairs(C.ALL_ORBS) do
    if o == orb_name then is_valid_orb = true; break end
  end
  if not is_valid_orb then
    return {ok=false, message="Slot 2 must contain a currency orb"}
  end

  -- Validate item has loot data
  local loot_data = require("src.serializer").read_tags(item_slot)
  if not loot_data then
    -- Item hasn't been rolled yet — roll it first (Normal roll as base)
    loot_data = {rarity=C.RARITY.NORMAL, prefixes={}, suffixes={}, rerolls=0}
  end

  -- Determine entity type for affix pool
  local item_proto = prototypes.item[item_slot.name]
  local entity_type, entity_name
  if item_proto then
    local pr = item_proto.place_result
    if pr then entity_type = pr.type; entity_name = pr.name end
  end
  if not entity_type then
    -- Armor or unknown — use "armor" as type
    entity_type = "armor"; entity_name = item_slot.name
  end

  -- Destruction check
  if Forge.should_destroy(loot_data.rarity) then
    inv[1].clear()
    orb_slot.count = orb_slot.count - 1
    return {ok=true, destroyed=true,
      message="[color=red]The item was destroyed by the rerolling process![/color]"}
  end

  -- Apply orb
  local result = Forge.apply_orb(orb_name, loot_data, entity_type, entity_name,
    player and player.force or nil)
  if not result.ok then
    return {ok=false, message=result.error}
  end

  -- Write new tags back to item
  Serializer.write_tags(item_slot, result.result)

  -- Update item label
  local base = item_proto and Naming.get_base_name(item_slot.name) or item_slot.name
  item_slot.label = Naming.build_name(base, result.result.rarity,
    result.result.prefixes, result.result.suffixes)

  -- Consume orb
  orb_slot.count = orb_slot.count - 1

  return {ok=true, destroyed=false, message="Reroll successful!"}
end

return Forge
