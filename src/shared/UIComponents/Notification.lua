local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local UIComponents = script.Parent
local CustomButton1 = require(UIComponents.CustomButton1)
local BaseFrame = require(UIComponents.BaseFrame)

local Question = Roact.Component:extend("Notification")

function Question:render()
    local FrameExample

    local NotificationFrame = Roact.createElement(BaseFrame, {
        Text = self.props.Text,
        Callback = self.props.Callback,
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(.4, .5),
        OpenOnMount = true,
        ZIndex = -5,
        __GET = function(self)
            FrameExample = self
        end
    }, {
        Title = Roact.createElement("TextLabel",{
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(-0.2, -0.1),
            Rotation = -10,
            Size = UDim2.fromScale(0.4, 0.2),
            TextScaled = true,
            Font = Enum.Font.FredokaOne,
            Text = "Hey!",
            TextColor3 = Color3.fromHex("ffffff")
        },{
            Roact.createElement("UIStroke", {
                Thickness = 5,
                Color = Color3.fromHex("ffdd34")
            })
        }),
        CloseButton = Roact.createElement(CustomButton1, {
            Position = UDim2.fromScale(1.005, -.025),
            AspectRatio = 1,
            Size = UDim2.fromScale(.09, .2),
            Text = "X",

            CanTween = self.CanTween,

            Callback = function()
                FrameExample:Close()
                self.UnmountCallback()
            end
        }),
        MessageLabel = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            TextScaled = true,
            TextColor3 = Color3.fromHex("ffffff"),
            Position = UDim2.fromScale(.075, .1),
            Size = UDim2.fromScale(.83, .6),
            Font = Enum.Font.FredokaOne,

            Text = self.props.Text,
        }, {
            UIStroke = Roact.createElement("UIStroke", {
                Thickness = 4,
                Color = Color3.fromHex("ffdd34"),
            }),
        }),
        Okay = Roact.createElement(CustomButton1, {
            Name = "Okay",
            Position = UDim2.fromScale(0.5, 0.82),
            BackgroundColor3 = Color3.fromHex("7cff35"),
            StrokeColor = Color3.fromHex("61c228"),
            Size = UDim2.fromScale(.5, .14),
            Text = "OKAY!",

            Callback = function()
                FrameExample:Close()
                if self.UnmountCallback then
                    self.UnmountCallback()
                end
            end
        }),
    })

    return NotificationFrame
end

return Question