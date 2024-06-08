local Loader = require(game:GetService("ReplicatedFirst").Packages.loader)
local Components = script.Parent.Components

Loader.SpawnAll(
	Loader.LoadDescendants(Components, Loader.MatchesName("Component$")),
	"OnStart"
)