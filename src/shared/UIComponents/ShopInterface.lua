local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local ShopInterface = Roact.Component:extend("ShopInterface")

local UIComponents = script.Parent
local CustomButton2 = require(UIComponents.CustomButton2)

function ShopInterface:init()
    self.Callbacks = self.props.Callbacks
    self.CurrentItemName, self.UpdateItemName = Roact.createBinding(self.props.StartingItemName or "N/A")

    if self.props.ReturnExample then
        self.props.ReturnExample(self)
    end

    if _G.Interface then
        local InterfaceGui = _G.Interface.InterfaceRef:getValue()
        InterfaceGui.Enabled = false
    end
end

function ShopInterface:render()
    return Roact.createElement("ScreenGui", {}, {
        LeftArrow = Roact.createElement(CustomButton2, {
            Name = "LeftArrow",
            Position = UDim2.fromScale(.3, .8),
            Size = UDim2.fromScale(.05, .1),
            AspectRatio = 1,
            Squash = 8,
            Text = "<",

            Callback = self.Callbacks.LeftArrow
        }),
        RightArrow = Roact.createElement(CustomButton2, {
            Name = "RightArrow",
            Position = UDim2.fromScale(.7, .8),
            Size = UDim2.fromScale(.05, .1),
            AspectRatio = 1,
            Squash = 8,
            Text = ">",

            Callback = self.Callbacks.RightArrow
        }),
        BuyButton = Roact.createElement(CustomButton2, {
            Name = "BuyButton",
            Position = UDim2.fromScale(.5, .8),
            Size = UDim2.fromScale(.17, .1),
            AspectRatio = 3.5,
            Squash = 8,
            Text = "Buy",

            Callback = self.Callbacks.BuyButton
        }),
        ItemName = Roact.createElement("TextLabel", {
            Name = "ItemName",
            Position = UDim2.fromScale(.5, .1),
            Size = UDim2.fromScale(.17, .1),
            AnchorPoint = Vector2.new(.5, .5),
            BackgroundTransparency = 1,
            Font = Enum.Font.FredokaOne,
            TextScaled = true,
            TextColor3 = Color3.fromHex("ffffff"),
            Text = self.CurrentItemName
        }, {
            AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 3.5
            })
        })
    })
end

function ShopInterface:SetCallback(Index, Callback)
    self.Callbacks[Index] = Callback
end

function ShopInterface:willUnmount() 
    if _G.Interface then
        local InterfaceGui = _G.Interface.InterfaceRef:getValue()
        InterfaceGui.Enabled = true
    end
end

return ShopInterface