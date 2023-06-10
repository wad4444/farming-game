local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local UIComponents = script.Parent
local CustomButton1 = require(UIComponents.CustomButton1)
local BasePopUp = require(UIComponents.BasePopUp)

local Question = Roact.Component:extend("Notification")

function Question:render()
    local NotificationFrame = Roact.createElement(BasePopUp, {
        Text = self.props.Text,
        MessageLabelSize = UDim2.fromScale(.83, .55),
        Callback = self.props.Callback,
        UnmountCallback = self.props.UnmountCallback,
        Buttons = {
            Okay = Roact.createElement(CustomButton1, {
                Name = "Okay",
                Position = UDim2.fromScale(0.5, 0.82),
                BackgroundColor3 = Color3.fromHex("7cff35"),
                StrokeColor = Color3.fromHex("61c228"),
                Size = UDim2.fromScale(.5, .14),
                Text = "OKAY!",
            }),
        }
    })

    return NotificationFrame
end

return Question