local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local CmdrClient: ModuleScript = require(ReplicatedStorage:WaitForChild("CmdrClient"))
local CmdrCmds: TextChatCommand = TextChatService.Commands.cmds

CmdrCmds.Triggered:Connect(function() 
    CmdrClient:Show()
end)

CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })

