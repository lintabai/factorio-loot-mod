-- src/gui.lua
-- Tinkerer's Forge custom GUI.
-- Opens when player right-clicks the Forge container entity.
-- Shows: slot previews, destruction chance, Apply button, result message.

local C       = require("src.constants")
local Forge   = require("src.forge")
local Storage = require("src.storage")
local Naming  = require("src.naming")

local GUI = {}

local FRAME_NAME = "loot_forge_frame"

-- ── Build GUI ─────────────────────────────────────────────────────────────────

function GUI.open(player, forge_entity)
  GUI.close(player) -- prevent duplicate frames

  local screen = player.gui.screen
  local frame = screen.add{
    type="frame", name=FRAME_NAME,
    caption="[img=item/loot-tinkerers-forge]  Tinkerer's Forge",
    direction="vertical",
  }
  frame.auto_center = true

  -- Instruction label
  frame.add{type="label", caption="[color=#aaaaaa]Slot 1: item to reroll  |  Slot 2: currency orb[/color]"}

  -- Info row (destruction chance)
  local info = frame.add{type="label", name="loot_forge_info", caption=""}

  -- Apply button
  local btn_row = frame.add{type="flow", direction="horizontal"}
  btn_row.add{
    type="button", name="loot_forge_apply_btn",
    caption="Apply Orb",
    style="confirm_button",
  }
  btn_row.add{type="button", name="loot_forge_close_btn", caption="Close"}

  -- Result message label
  frame.add{type="label", name="loot_forge_result", caption=""}

  Storage.set_forge_gui(player.index, {
    forge_unit = forge_entity.unit_number,
    forge_entity = forge_entity,
  })

  GUI.refresh_info(player, forge_entity)
end

function GUI.close(player)
  local screen = player.gui.screen
  if screen[FRAME_NAME] then screen[FRAME_NAME].destroy() end
  Storage.clear_forge_gui(player.index)
end

-- Update the destruction chance label based on current item in slot 1
function GUI.refresh_info(player, forge_entity)
  local screen = player.gui.screen
  if not screen[FRAME_NAME] then return end
  local info_label = screen[FRAME_NAME]["loot_forge_info"]
  if not info_label then return end

  if not forge_entity or not forge_entity.valid then
    info_label.caption = "[color=red]Forge is invalid[/color]"
    return
  end

  local inv = forge_entity.get_inventory(defines.inventory.chest)
  if not inv then return end

  local item_slot = inv[1]
  if not item_slot.valid_for_read then
    info_label.caption = "[color=#aaaaaa]Awaiting item...[/color]"
    return
  end

  local loot_data = require("src.serializer").read_tags(item_slot)
  local rarity = loot_data and loot_data.rarity or C.RARITY.NORMAL
  local destroy_chance = C.REROLL_DESTRUCTION_CHANCE[rarity] or 0
  local color = C.RARITY_COLOR[rarity] or "#ffffff"

  local lines = {
    "Item: [color=" .. color .. "]" .. Naming.get_base_name(item_slot.name) .. "[/color]",
    "Rarity: [color=" .. color .. "]" .. rarity .. "[/color]",
  }
  if destroy_chance > 0 then
    local pct = math.floor(destroy_chance * 100)
    table.insert(lines, "[color=red]⚠ Destruction chance: " .. pct .. "% — cannot be undone![/color]")
  else
    table.insert(lines, "[color=green]No destruction risk[/color]")
  end

  -- Show current affixes
  if loot_data and (#loot_data.prefixes > 0 or #loot_data.suffixes > 0) then
    table.insert(lines, "")
    table.insert(lines, Naming.build_tooltip(rarity, loot_data.prefixes, loot_data.suffixes))
  end

  info_label.caption = table.concat(lines, "\n")
end

-- ── GUI event handlers ────────────────────────────────────────────────────────

function GUI.on_gui_click(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  local name = event.element and event.element.name
  if not name then return end

  if name == "loot_forge_close_btn" then
    GUI.close(player)
    return
  end

  if name == "loot_forge_apply_btn" then
    local gui_data = Storage.get_forge_gui(player.index)
    if not gui_data then return end

    local forge_entity = gui_data.forge_entity
    if not forge_entity or not forge_entity.valid then
      GUI.close(player)
      return
    end

    local result = Forge.process(forge_entity, player)

    -- Update result label
    local screen = player.gui.screen
    if screen[FRAME_NAME] then
      local result_label = screen[FRAME_NAME]["loot_forge_result"]
      if result_label then
        if result.ok then
          if result.destroyed then
            result_label.caption = "[color=red]" .. result.message .. "[/color]"
          else
            result_label.caption = "[color=green]" .. result.message .. "[/color]"
          end
        else
          result_label.caption = "[color=orange]" .. result.message .. "[/color]"
        end
      end
      GUI.refresh_info(player, forge_entity)
    end
    return
  end
end

function GUI.on_gui_opened(event)
  if event.gui_type ~= defines.gui_type.entity then return end
  local entity = event.entity
  if not entity or not entity.valid then return end
  if entity.name ~= C.FORGE_ENTITY then return end

  local player = game.get_player(event.player_index)
  if not player then return end

  -- Close default container GUI, open ours
  player.opened = nil
  GUI.open(player, entity)
end

function GUI.on_gui_closed(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local screen = player.gui.screen
  if screen[FRAME_NAME] then
    GUI.close(player)
  end
end

return GUI
