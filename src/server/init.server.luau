local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local Log = require(ReplicatedFirst.Packages.log)
local RemoteManager = require(ReplicatedFirst.Packages.remotemanager)

local PlayerDataStore = DataStoreService:GetDataStore("PlayerDataStore")

local SessionData = {}
local SaveDebounces = {}

local Logger = Log.new()

local SAVE_INTERVAL = 60 -- Time in seconds between DataStore updates

------------------------------------------------------------------------------------------------
-- DATASTORE HANDLER
------------------------------------------------------------------------------------------------

function PlayerAdded(player)
    local PlayerData = nil
    local success = nil
    local attempt = 1
    repeat
        success, PlayerData = pcall(function()
            return PlayerDataStore:GetAsync(player.UserId)
        end)
        attempt += 1
        if not success then
            Logger:AtInfo():Log("Player data failed: " .. PlayerData)
        end
    until success or attempt == 5

    if success then
        Logger:AtInfo():Log("Data loaded for", player.UserId)
        if not PlayerData then
            Logger:AtInfo():Log("Assigning default player data")
            PlayerData = {
                ["Phase"] = 1,
                ["GrammarJacks"] = 1,
                ["HellJacks"] = 1,
                ["DeathJacks"] = 1,
                
                ["Total_DeathJacks"] = 0,  
                ["Total_GrammarJacks"] = 0,
                ["Total_HellJacks"] = 0,
            }
        end
        SessionData[player.UserId] = PlayerData
    else
        Logger:AtInfo():Log("Unable to get data for", player.UserId)
        player:Kick("Unable to load data. Try again later.")
    end
end

function SavePlayerData(player)
    local success, errorMsg
    local attempt = 1

    repeat
        success, errorMsg = pcall(function()
            PlayerDataStore:SetAsync(player.UserId, SessionData[player.UserId])
        end)
        attempt += 1
        if not success then
            Logger:AtInfo():Log("Player data save failed: " .. errorMsg)
        end
    until success or attempt == 5

    if success then
        Logger:AtInfo():Log("Data saved for", player.UserId)
    else
        Logger:AtInfo():Log("Unable to save data for", player.UserId)
    end
end

function PlayerLeaving(player)
    if SessionData[player.UserId] then
        SavePlayerData(player)
    end
end

function ServerShutdown()
    Logger:AtWarning():Log("Server shutting down")
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            PlayerLeaving(player)
        end)
    end
end

------------------------------------------------------------------------------------------------
-- REMOTE MANAGEMENT
------------------------------------------------------------------------------------------------

local lastNumbers = {}

RemoteManager:Get("BindableEvent", 'UpdateJackAmount'):Connect(function(player, jackType, jackAmount)
    if not lastNumbers[player.UserId] then
        lastNumbers[player.UserId] = {}
    end

    local lastNumber = lastNumbers[player.UserId][jackType]

    if lastNumber ~= jackAmount then
        lastNumbers[player.UserId][jackType] = jackAmount
        print("New number:", jackAmount)

        if not SessionData[player.UserId] then
            return
        end
        SessionData[player.UserId][jackType] = jackAmount

        local totalKey = "Total_" .. jackType
        SessionData[player.UserId][totalKey] = (SessionData[player.UserId][totalKey] or 0) + 1

        if not SaveDebounces[player.UserId] or os.time() - SaveDebounces[player.UserId] > SAVE_INTERVAL then
            SaveDebounces[player.UserId] = os.time()
            SavePlayerData(player)
        end
    end
end)

------------------------------------------------------------------------------------------------
-- END
------------------------------------------------------------------------------------------------

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerLeaving)
game:BindToClose(ServerShutdown)