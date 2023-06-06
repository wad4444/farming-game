local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Roact = require(Shared.Libraries.Roact)
local UIComponents = require(Shared.UIComponents)

local PopUps = {}

function PopUps.Question(QuestionText : string)
    local Interface = _G.Interface.InterfaceRef:getValue()
    
    local Tree
    local Result 

    local NewPopUp = Roact.createElement(UIComponents.Question, {
        Text = QuestionText,
        UnmountCallback = function()
            Roact.unmount(Tree)
        end,
        Callback = function(_Result)
            Result = _Result
        end
    })

    Tree = Roact.mount(NewPopUp, Interface)

    while Result == nil do
        task.wait()
    end

    return Result
end

function PopUps.Notification(Text : string)
    local Interface = _G.Interface.InterfaceRef:getValue()
    
    local Tree
    local NewPopUp = Roact.createElement(UIComponents.Notification, {
        Text = Text,
        UnmountCallback = function()
            Roact.unmount(Tree)
        end,
    })

    Tree = Roact.mount(NewPopUp, Interface)
end

return PopUps