local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Roact = require(Shared.Libraries.Roact)
local UIComponents = require(Shared.UIComponents)

local Notifications = {}

function Notifications.PopUp(Question : string)
    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    local Tree
    local Result 

    local NewPopUp = Roact.createElement(UIComponents.PopUp, {
        Text = Question,
        UnmountCallback = function()
            Roact.unmount(Tree)
        end,
        Callback = function(_Result)
            Result = _Result
        end
    })

    Tree = Roact.mount(NewPopUp, PlayerGui)

    while Result == nil do
        task.wait()
    end

    return Result
end

return Notifications