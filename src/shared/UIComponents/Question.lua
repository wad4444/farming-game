local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local UIComponents = script.Parent
local CustomButton1 = require(UIComponents.CustomButton1)
local BaseFrame = require(UIComponents.BaseFrame)

local Question = Roact.Component:extend("Question")

function Question:render()
    local FrameExample

    local NewQuestionFrame = Roact.createElement(BaseFrame, {
        Text = self.props.Text,
        Callback = self.props.Callback,
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(.4, .5),
        OpenOnMount = true,
        __GET = function(self)
            FrameExample = self
        end
    }, {
        Option1 = Roact.createElement(CustomButton1, {
            Name = "Option1",
            Position = UDim2.fromScale(0.27, 0.82),
            BackgroundColor3 = Color3.fromHex("7cff35"),
            StrokeColor = Color3.fromHex("61c228"),
            Size = UDim2.fromScale(.19, .11),
            Text = "YES",

            Callback = function()
                self.props.Callback(true) 
                FrameExample:Close()
                self.props.UnmountCallback()
            end,
        }),
        Option2 = Roact.createElement(CustomButton1, {
            Name = "Option2",
            Position = UDim2.fromScale(0.67, 0.82),
            BackgroundColor3 = Color3.fromHex("ff3939"),
            StrokeColor = Color3.fromHex("c22a2a"),
            Size = UDim2.fromScale(.19, .11),
            Text = "NO",

            Callback = function()
                self.props.Callback(false) 
                FrameExample:Close()
                self.props.UnmountCallback()
            end,
        }),
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
                self.props.Callback(false)
                FrameExample:Close()
                self.props.UnmountCallback()
            end
        }),
        MessageLabel = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            TextScaled = true,
            TextColor3 = Color3.fromHex("ffffff"),
            Position = UDim2.fromScale(.075, .05),
            Size = UDim2.fromScale(.83, .65),
            Font = Enum.Font.FredokaOne,

            Text = self.props.Text,
        }, {
            UIStroke = Roact.createElement("UIStroke", {
                Thickness = 4,
                Color = Color3.fromHex("ffdd34"),
            }),
        }),
    })

    return NewQuestionFrame
end

return Question