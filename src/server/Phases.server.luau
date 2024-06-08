local DataStoreService = game:GetService("DataStoreService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataStore: DataStore = DataStoreService:GetDataStore("PlayerDataStore")
local RemoteManager = require(ReplicatedFirst.Packages.remotemanager)
local PhasesInformation = require(ReplicatedStorage.Shared.PhasesInformation)

------------------------------------------------------------------------------------------------
-- COMPONENT LOADER
------------------------------------------------------------------------------------------------

local ComponentFolder: Folder = ServerScriptService.Server.Components
local Components = {}

for i, component in ipairs(ComponentFolder:GetChildren()) do
    Components[component.Name] = require(component)
end


------------------------------------------------------------------------------------------------
-- PHASE 1 & 2
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
-- PHASE 3 
------------------------------------------------------------------------------------------------

RemoteManager:Get("RemoteEvent", "StartPhase3"):Connect(function()
    
end)
