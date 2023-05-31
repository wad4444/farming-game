local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Shared.Libraries.Roact)
local ClientDataHandler = require(ReplicatedStorage.Shared.Core.ClientDataHandler)

local UIComponents = script.Parent

local StatBar = Roact.Component:extend("StatBar")

function StatBar:init()
    self.ValueName = self.props.Path[#self.props.Path]

    self:setState({
        CounterValue = 0
    })
end

function StatBar:render()
    local BarElement = Roact.createElement("Frame", {
        Position = self.props.Position,
        Name = "Background",
        Size = self.props.Size or UDim2.fromScale(0.1325, 0.05),
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
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#ffffff")),
                ColorSequenceKeypoint.new(0.45, Color3.fromHex("#ffffff")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#d1d1d1"))
            })
        }),
        Counter = Roact.createElement("TextLabel",{
            Name = "Counter",
            Position = UDim2.fromScale(0.09, 0.11),
            Size = UDim2.fromScale(0.65, 0.75),
            Font = Enum.Font.FredokaOne,
            TextColor3 = Color3.fromHex("ffffff"),
            BackgroundTransparency = 1,
            TextScaled = true,

            Text = self.ValueName..": "..self.state.CounterValue
        },{
            TextGradient = Roact.createElement("UIGradient",{
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHex("#ffc20c")),
                    ColorSequenceKeypoint.new(0.35, Color3.fromHex("#ffc20c")),
                    ColorSequenceKeypoint.new(1, Color3.fromHex("#ff9602"))
                })
            })
        })
    })

    return BarElement
end

function StatBar:didMount()
    self.IsActive = true

    ClientDataHandler.ChangeBind(self.props.Path, function(NewValue)
        if not self.IsActive then
            return
        end

        self:setState({
            CounterValue = NewValue,
        })
    end)
end

function StatBar:willUnmount()
    self.IsActive = false
end

return StatBar