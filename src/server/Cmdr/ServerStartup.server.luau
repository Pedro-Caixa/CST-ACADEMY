local ServerStorage = game:GetService("ServerStorage")

local Cmdr = require(ServerStorage.Packages.Cmdr)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterHooksIn(script.Parent.Hooks)
Cmdr:RegisterCommandsIn(script.Parent.Commands)