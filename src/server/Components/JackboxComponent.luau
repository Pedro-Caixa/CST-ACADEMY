local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Component = require(game["ReplicatedFirst"].Packages.component)
local Zone = require(game["ReplicatedFirst"].Packages.zoneplus)
local numberToWords = require(game.ReplicatedFirst.Number2Words)
local DiscordWebhook = require(game["ReplicatedFirst"].Utils.DiscordWebhook)
local RemoteManager = require(game["ReplicatedFirst"].Packages.remotemanager)

local Embed = DiscordWebhook.Embed
local Webhook = DiscordWebhook.Webhook

local Jackbox = Component.new({
    Tag = "Jackbox",
    Ancestors = {workspace},
})

local function capitalizeFirstLetter(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

local function getGrammarJackInput(number)
    local word = numberToWords(number)
    local capitalizedWord = capitalizeFirstLetter(word)
    return capitalizedWord .. "."
end

local function getHellJacksInput(number)
    local word = numberToWords(number):upper() 
    local noSpacesWord = word:gsub(" ", "") 
    local letters = {}
    for letter in noSpacesWord:gmatch(".") do
        table.insert(letters, letter)
    end
    table.insert(letters, numberToWords(number):upper()) 
    return letters
end

local function getDeathJacksInput(number)
    local word = getGrammarJackInput(number) 
    local reversedWord = string.reverse(word) 
    local letters = {}
    for letter in reversedWord:gmatch(".") do
        table.insert(letters, letter)
    end
    table.insert(letters, reversedWord) 
    return letters
end

local function getExpectedInput(number, exercise)
    if exercise == "GrammarJacks" then
        return { getGrammarJackInput(number) }
    elseif exercise == "HellJacks" then
        return getHellJacksInput(number)
    elseif exercise == "DeathJacks" then
        return getDeathJacksInput(number)
    end
end


function Jackbox:Construct()
    self.Zone = Zone.new(self.Instance)
    self.JackType = self.Instance:GetAttribute("JackType") or "GrammarJacks"
    self.hasJackStarted = false
    self.userProgress = {}

    local function onPlayerChatted(player, message)
        local userId = player.UserId
        if self:checkUserInput(userId, message) then
            local progress = self.userProgress[userId]
            if progress.lastInputCorrect then
                progress.number = progress.number + 1
                progress.expectedInput = getExpectedInput(progress.number, self.JackType)
                progress.lastInputCorrect = false
                print("User " .. player.Name .. " is correct! Next number is " .. progress.number)
            end
            RemoteManager:Get('BindableEvent', 'UpdateJackAmount')(player, self.JackType, progress.number)
        else
            self:_resetUserProgress(userId)
            RemoteManager:Get('BindableEvent', 'UpdateJackAmount')(player, self.JackType, 1)
        end
    end
    

    self.Zone.playerEntered:Connect(function(player)
        self.CurrentPlayer = player
        self:InitializeUser(player)        
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end)

    self.Zone.playerExited:Connect(function(player)
        if self.CurrentPlayer == player then
            self.CurrentPlayer = nil 
        end
    end)
end

function Jackbox:checkUserInput(userId, input)
    local progress = self.userProgress[userId]
    local expectedInput = progress.expectedInput

    if input == expectedInput[1] then
        table.remove(expectedInput, 1)
        if #expectedInput == 0 then
            progress.lastInputCorrect = true
        end
        return true
    else
        progress.lastInputCorrect = false
        return false
    end
end

function Jackbox:InitializeUser(player)
    print("Initialized", player.Name)
    self.userProgress[player.UserId] = {
        number = 1,
        expectedInput = {},
        lastInputCorrect = false
    }
    local expectedInput = getExpectedInput(self.userProgress[player.UserId].number, self.JackType)
    for _, letter in ipairs(expectedInput) do
        print(letter)
        table.insert(self.userProgress[player.UserId].expectedInput, letter)
    end
end

function Jackbox:_resetUserProgress(userId)
    self.userProgress[userId] = {
        number = 1,
        expectedInput = getExpectedInput(1, self.JackType), 
        lastInputCorrect = false
    }
    if self.CurrentPlayer and self.CurrentPlayer.UserId == userId then
        print("Progress reset for", self.CurrentPlayer.Name)
    end
end

function Jackbox:Start()
    print("Jackbox has been started")
end

return Jackbox
