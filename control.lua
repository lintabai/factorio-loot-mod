-- control.lua
-- Runtime entry point. Initializes storage and registers all events.

local Storage = require("src.storage")
local Events  = require("src.events")

-- Top-level registration so handlers are bound during script load
-- (needed for joining-player parity in multiplayer).
Events.register()

script.on_init(function()
  Storage.init()
end)

script.on_load(function()
  -- on_load: no game state access; handlers already bound at top level.
end)

script.on_configuration_changed(function()
  Storage.init()
end)
