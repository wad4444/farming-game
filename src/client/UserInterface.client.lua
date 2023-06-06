local IsLoaded = game:IsLoaded() or game.Loaded:Wait()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Roact = require(Shared.Libraries.Roact)
local CustomElements = require(Shared.UIComponents)
local PopUps = require(Shared.Core.PopUps)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Interface = Roact.Component:extend("UserInterface")

function Interface:init()
    if _G.Interface then
        error("Can't create a second interface :<")
    end

    self.InterfaceRef = Roact.createRef()
    _G.Interface = self
end

function Interface:render()
    return Roact.createElement("ScreenGui",{
        ResetOnSpawn = false,
        [Roact.Ref] = self.InterfaceRef
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
        }),
    })
end

Roact.mount(Roact.createElement(Interface), PlayerGui)

Remotes.RequestSelling.OnClientInvoke = function(CirlceSettings, Currency1Amount, Currency2Amount)
    local Currency1Name = CirlceSettings.Currency1[#CirlceSettings.Currency1]
    local Currency2Name = CirlceSettings.Currency2[#CirlceSettings.Currency2]

    local SellsFor = Currency1Amount * CirlceSettings.ExchangeRate
    local Question = "Do you want to sell "..Currency1Amount.." "..Currency1Name.." for "..SellsFor.." "..Currency2Name

    return PopUps.Question(Question)
end

task.delay(5,function()
    PopUps.Notification("How's it goiun")
end)