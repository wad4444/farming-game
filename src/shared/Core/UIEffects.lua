local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage:WaitForChild("Packages")

local UIComponents = require(Shared.UIComponents)
local Roact = require(Packages.Roact)

local UIEffects = {}

function UIEffects.Fade(...)
    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local Tree

    local NewFade = Roact.createElement(UIComponents.Fade, {
        Timestamps = {...},
        UnmountCallback = function()
            Roact.unmount(Tree)
        end
    })

    Tree = Roact.mount(NewFade, PlayerGui)
end

return UIEffects