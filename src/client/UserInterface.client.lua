local IsLoaded = game:IsLoaded() or game.Loaded:Wait()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Roact = require(Shared.Libraries.Roact)
local CustomElements = require(Shared.UIComponents)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Interface = Roact.createElement("ScreenGui",{
    ResetOnSpawn = false
},{
    CoinsBar = Roact.createElement(CustomElements.StatBar, {
        IconId = "rbxassetid://13589076524",
        Position = UDim2.fromScale(0.85,0.5),
        Path = {"Coins"}
    }),
    WheatBar = Roact.createElement(CustomElements.StatBar, {
        IconId = "rbxassetid://13588650780",
        Position = UDim2.fromScale(0.85,0.58),
        Path = {"Crops", "Wheat"}
    })
})

Roact.mount(Interface, PlayerGui)