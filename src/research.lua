-- src/research.lua
-- Handles on_research_finished for Biter-Attracting lab affix
-- and any research-completion effects.

local C       = require("src.constants")
local Affixes = require("src.affixes.init")
local Storage = require("src.storage")

local Research = {}

function Research.on_research_finished(event)
  local tech  = event.research
  local force = tech.force

  -- Check all placed labs on all surfaces for the Biter-Attracting affix
  for _, surface in pairs(game.surfaces) do
    -- Only look at labs belonging to this force
    local labs = surface.find_entities_filtered{
      type = "lab",
      force = force,
    }
    for _, lab in ipairs(labs) do
      if lab.valid then
        local data = Storage.get_entity_data(lab.unit_number)
        if data then
          Research.check_biter_spawn(lab, data, surface)
          Research.check_research_bonus(lab, data, tech)
        end
      end
    end
  end
end

function Research.check_biter_spawn(lab, data, surface)
  for _, inst in ipairs(data.prefixes or {}) do
    local def = Affixes.get_def(inst.id)
    if def and def.effect == C.EFFECT.SPAWN_BITERS then
      if math.random() < inst.value then
        -- Spawn a small biter group near the lab
        local pos = lab.position
        local spawn_pos = surface.find_non_colliding_position(
          "small-biter", {x=pos.x + 15, y=pos.y}, 10, 1
        )
        if spawn_pos then
          surface.create_entity{
            name = "unit-spawner",
            position = spawn_pos,
            force = "enemy",
          }
          -- Immediately trigger a small attack
          surface.create_entity{
            name = "small-biter",
            position = spawn_pos,
            force = "enemy",
          }
          local player_msg = "[color=red]A Biter-Attracting lab has attracted enemy attention![/color]"
          for _, player in pairs(game.players) do
            if player.force == lab.force then
              player.print(player_msg)
            end
          end
        end
      end
    end
  end
end

function Research.check_research_bonus(lab, data, tech)
  for _, inst in ipairs(data.suffixes or {}) do
    local def = Affixes.get_def(inst.id)
    if def and def.is_research_bonus then
      if math.random() < inst.value then
        -- Grant a small bonus progress on the next queued tech
        -- In Factorio 2.x this is done by adding to research_progress
        if tech.force.current_research then
          local current = tech.force.research_progress or 0
          tech.force.research_progress = math.min(1, current + 0.05)
        end
      end
    end
  end
end

return Research
