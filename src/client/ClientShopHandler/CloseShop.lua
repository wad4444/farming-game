local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Core = Shared.Core

local UIEffects = require(Core.UIEffects)

return function(FinishedCallback)
    task.spawn(UIEffects.Fade,1,1,1)
    task.wait(1)

    local Camera = game.Workspace.CurrentCamera
    Camera.CameraType = Enum.CameraType.Custom
    
    if FinishedCallback then
        FinishedCallback()
    end
end