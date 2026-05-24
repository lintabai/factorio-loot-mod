-- control.lua
-- Runtime entry point. Initializes storage and registers all events.

local Storage = require("src.storage")
local Events  = require("src.events")

script.on_init(function()
  Storage.init()
  Events.register()
end)

script.on_load(function()
  -- on_load: re-register event handlers (storage already exists, don't re-init)
  Events.register()
end)

script.on_configuration_changed(function(data)
  -- Re-init any missing storage fields when mod is updated
  Storage.init()
end)
