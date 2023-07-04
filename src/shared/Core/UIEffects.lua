local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage:WaitForChild("Packages")

local UIComponents = Shared.UIComponents
local Fade = require(UIComponents.Fade)
local ClickCircle = require(UIComponents.ClickCircle)

local Roact = require(Packages.Roact)

local UIEffects = {}

function UIEffects.Fade(...)
    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")

    local Tree

    local NewFade = Roact.createElement(Fade, {
        Timestamps = {...},
        UnmountCallback = function()
            Roact.unmount(Tree)
        end
    })

    Tree = Roact.mount(NewFade, PlayerGui)
end

function UIEffects.Click()
    local Player = Players.LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")  
    local MousePos = UserInputService:GetMouseLocation()

    local CircleTree
    local NewClickCircle = Roact.createElement(ClickCircle, {
        Position = UDim2.fromOffset(MousePos.X, MousePos.Y),
        UnmountCallback = function()
            Roact.unmount(CircleTree)
        end
    })

    CircleTree = Roact.mount(NewClickCircle, PlayerGui)
end

return UIEffects