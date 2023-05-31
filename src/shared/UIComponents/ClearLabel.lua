local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Shared.Libraries.Roact)

local ClearLabel = Roact.Component:extend("ClearLabel")

function ClearLabel:render()
    local NewLabel = Roact.createElement("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        TextScaled = true,
        Font = self.props.Font,
        Size = self.props.Size,
        Position = self.props.Position,
        TextColor3 = self.props.TextColor3,
        TextStrokeColor3 = self.props.TextStrokeColor3,
        Text = self.props.Text
    })

    return NewLabel
end

return ClearLabel