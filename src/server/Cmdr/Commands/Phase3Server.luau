return function(context, player: Player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

        local jackboxes: {Model} = {}

        for _, model in ipairs(game.Workspace:GetDescendants()) do
            if model:IsA("Model") and model:HasTag("Jackbox") then
                table.insert(jackboxes, model)
            end
        end

        if #jackboxes > 0 then
            local jackbox: Model = jackboxes[math.random(#jackboxes)] 
            local position: CFrame = jackbox.WorldPivot
            player.Character.HumanoidRootPart.CFrame = position

            return "Teleported to Jackbox."
        else
            return "No Jackbox found in the workspace."
        end
    end

    return "Player has no character or HumanoidRootPart."
end
