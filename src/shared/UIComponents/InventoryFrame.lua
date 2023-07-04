local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Roact = require(Packages.Roact)
local Shared = ReplicatedStorage:WaitForChild("Shared")

local UIComponents = script.Parent
local CustomButton1 = require(UIComponents.CustomButton1)
local CustomButton2 = require(UIComponents.CustomButton2)
local Viewport2 = require(UIComponents.Viewport2)
local BaseFrame = require(UIComponents.BaseFrame)

local InventoryFrame = Roact.Component:extend("InventoryFrame1")
local ClientDataHandler = require(Shared.Core.ClientDataHandler)

function InventoryFrame:init()
    ClientDataHandler.Bind({"Items"}, function(Items)
        self:setState({
            Items = Items
        })
    end)

    if self.props.__GET then
        self.props.__GET(self)
    end
end

function InventoryFrame:render()
    local ItemsUI = {}
    ItemsUI['Grid'] = Roact.createElement("UIGridLayout", {
        CellSize = UDim2.fromScale(.1, .1)
    })

    local MainFrame = Roact.createElement(BaseFrame, {
        AnchorPoint = Vector2.new(.5, .5),
        Position = self.props.Position or UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(.6, .6),
        BackgroundTransparency = 1,

        __GET = function(Example)
            self.FrameExample = Example
        end
    }, {
        AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1.6
        }),
        BackFrame1 = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.fromHex("ffdd34"),
            Size = UDim2.fromScale(1.05,1.025),
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),
            Rotation = -3,
            ZIndex = 0,
        }, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(.05, 0)
            })
        }),
        BackFrame2 = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.fromHex("d1b22b"),
            Size = UDim2.fromScale(1.05,1.05),
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),
            Rotation = 3,
            ZIndex = -1,
        }, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(.05, 0)
            })
        }),
        Pattern = Roact.createElement("ImageLabel", {
            Image = "rbxassetid://13606808259",
            BackgroundColor3 = Color3.fromHex("f7f7f7"),
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),
            Size = UDim2.fromScale(.95, .925),
            BackgroundTransparency = 0,
            ZIndex = 2,
            ImageTransparency = .9
        }, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(.05, 0)
            }),
        }),
        ItemsFrame = Roact.createElement("ScrollingFrame", {
            AnchorPoint = Vector2.new(.5, .5),
            Position = UDim2.fromScale(.5, .5),
            Size = UDim2.fromScale(.925, .925),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarImageColor3 = Color3.fromHex("d5d5d5"),
            ZIndex = 3,
        }, ItemsUI),
        CloseButton = Roact.createElement(CustomButton1, {
            Position = UDim2.fromScale(1, -0.01),
            Size = UDim2.fromScale(.15, .15),
            AspectRatio = 1,
            ZIndex = 3,
            Text = "X",

            Callback = self.props.ToggleCallback
        }),
        Title = Roact.createElement("TextLabel", {
            Position = UDim2.fromScale(0.1, 0),
            AnchorPoint = Vector2.new(.5, .5),
            Size = UDim2.fromScale(.65, .4),
            ZIndex = 3,
            Rotation = -5,
            Text = "Inventory",
            BackgroundTransparency = 1,
            TextScaled = true,
            Font = Enum.Font.FredokaOne,
            TextColor3 = Color3.fromHex("ffffff")
        }, {
            UIStroke = Roact.createElement("UIStroke", {
                Thickness = 5,
                Color = Color3.fromHex("ffdd34")
            }),
            TextSizeConstraint = Roact.createElement("UITextSizeConstraint", {
                MaxTextSize = 85,
                MinTextSize = 1
            })
        })
    })

    return MainFrame
end

function InventoryFrame:Open()
    self.FrameExample:Open()
end

function InventoryFrame:Close()
    self.FrameExample:Close()
end

return InventoryFrame
