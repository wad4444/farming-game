local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Shared.Libraries.Roact)

local UIComponents = script.Parent
local ClearLabel = require(UIComponents.ClearLabel)

local StatBar = Roact.Component:extend("StatBar")

function StatBar:render()
    local BarElement = Roact.createElement("Frame", {
        Position = self.props.Position,
        Name = "Background",
        Size = UDim2.fromScale(0.12, 0.05),
        BackgroundColor3 = Color3.fromHex("ffffff")
    }, {
        Icon = Roact.createElement("ImageLabel", {
            Name = "Icon",
            Image = self.props.IconId,
            Position = UDim2.fromScale(0.75, -0.43),
            Size = UDim2.fromScale(0.35, 1.8),
            BackgroundTransparency = 1
        }, {
            Roact.createElement("UIAspectRatioConstraint")
        }),
        UICorner = Roact.createElement("UICorner",{
            CornerRadius = UDim.new(1,0)
        }),
        UIStroke = Roact.createElement("UIStroke",{
            Color = Color3.fromHex("#ffdd34"),
            Thickness = 3,
        }),
        UIGradient = Roact.createElement("UIGradient",{
            Color = ColorSequence.new(
                {
                    ColorSequenceKeypoint.new(0, Color3.fromHex("#ffffff")),
                    ColorSequenceKeypoint.new(0.45, Color3.fromHex("#ffffff")),
                    ColorSequenceKeypoint.new(1, Color3.fromHex("#d1d1d1"))
                }
            )
        }),
        Counter = Roact.createElement(ClearLabel,{
            Name = "Counter",
            Position = UDim2.fromScale(0.09, 0.11),
            Size = UDim2.fromScale(0.65, 0.75),
            Font = Enum.Font.FredokaOne
        })
    })

    return BarElement
end

return StatBar