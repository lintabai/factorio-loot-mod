-- src/research.lua
-- Handles on_research_finished for Biter-Attracting lab affix
-- and any research-completion effects.

local C       = require("src.constants")
local Affixes = require("src.affixes.init")
local Storage = require("src.storage")

local Research = {}

function Research.on_research_finished(event)
  local tech  = event.research
  if not tech or not tech.valid then return end
  local force = tech.force

  for _, surface in pairs(game.surfaces) do
    local labs = surface.find_entities_filtered{type="lab", force=force}
    for _, lab in ipairs(labs) do
      if lab.valid then
        local data = Storage.get_entity_data(lab.unit_number)
        if data then
          Research.check_biter_spawn(lab, data, surface)
          Research.check_research_bonus(lab, data, force)
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
        local pos = lab.position
        -- Spawn 2-4 biters (not a spawner!) in a small radius
        local count = math.random(2, 4)
        for _ = 1, count do
          local spawn_pos = surface.find_non_colliding_position(
            "small-biter",
            {x = pos.x + math.random(10, 20), y = pos.y + math.random(-10, 10)},
            12, 1
          )
          if spawn_pos then
            surface.create_entity{
              name     = "small-biter",
              position = spawn_pos,
              force    = "enemy",
            }
          end
        end
        local msg = "[color=red]A Biter-Attracting lab drew enemies![/color]"
        for _, player in pairs(lab.force.players or {}) do
          player.print(msg)
        end
      end
    end
  end
end

function Research.check_research_bonus(lab, data, force)
  for _, inst in ipairs(data.suffixes or {}) do
    local def = Affixes.get_def(inst.id)
    if def and def.is_research_bonus then
      if math.random() < inst.value and force.current_research then
        local current = force.research_progress or 0
        force.research_progress = math.min(1, current + 0.05)
      end
    end
  end
end

return Research
