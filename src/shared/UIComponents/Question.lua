local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local UIComponents = script.Parent
local CustomButton1 = require(UIComponents.CustomButton1)
local BasePopUp = require(UIComponents.BasePopUp)

local Question = Roact.Component:extend("Question")

function Question:render()
    local NewQuestionFrame = Roact.createElement(BasePopUp, {
        Text = self.props.Text,
        MessageLabelSize = UDim2.fromScale(.83, .55),
        Callback = self.props.Callback,
        UnmountCallback = self.props.UnmountCallback,
        Buttons = {
            Option1 = Roact.createElement(CustomButton1, {
                Name = "Option1",
                Position = UDim2.fromScale(0.27, 0.82),
                BackgroundColor3 = Color3.fromHex("7cff35"),
                StrokeColor = Color3.fromHex("61c228"),
                Size = UDim2.fromScale(.19, .11),
                Text = "YES",
    
                CallbackFunction = self.props.Callback,
                CallbackArguments = {true},
            }),
            Option2 = Roact.createElement(CustomButton1, {
                Name = "Option2",
                Position = UDim2.fromScale(0.67, 0.82),
                BackgroundColor3 = Color3.fromHex("ff3939"),
                StrokeColor = Color3.fromHex("c22a2a"),
                Size = UDim2.fromScale(.19, .11),
                Text = "NO",
    
                CallbackFunction = self.props.Callback,
                CallbackArguments = {false},
            }),
        }
    })

    self.NewQuestionFrame = NewQuestionFrame

    return NewQuestionFrame
end

return Question