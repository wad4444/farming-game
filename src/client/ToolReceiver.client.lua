local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Types = {
    Default = function(Tool)
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
        return
    end

    warn("The SetupType you mentioed in the server script doesn't exist!\n Please update the client script.\n Setup type: "..SetupType)
end)