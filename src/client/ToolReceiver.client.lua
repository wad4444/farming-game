local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Types = {
    Default = function(Tool : Tool)
        local Bridge = Tool:WaitForChild("Bridge")
        
        Tool.Activated:Connect(function()
            Bridge:InvokeServer("Activated")
        end)
    end
}

Remotes.SetupTool.OnClientEvent:Connect(function(SetupType, ...)
    local FindType = Types[SetupType]

    if FindType then
        FindType(...)
    else
        warn("The SetupType you mentioed in the server script doesn't exist! Please update the client script")
    end
end)