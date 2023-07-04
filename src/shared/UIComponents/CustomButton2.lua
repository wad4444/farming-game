local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Core = ReplicatedStorage:WaitForChild("Shared").Core 
local UIEffects = require(Core.UIEffects)

local Roact = require(Packages.Roact)

local CustomButton2 = Roact.Component:extend("CustomButton2")

function CustomButton2:init()
    self.ButtonRef = Roact.createRef()
    self.TweenInfo = TweenInfo.new(.15)
end

function CustomButton2:render()
    local ChildrenTable = {
        TextLabel = self.props.Text and Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            TextScaled = true,
            Font = self.props.Font or Enum.Font.FredokaOne,
            TextColor3 = self.props.TextColor3 or Color3.fromHex("ffffff"),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(.5,.5),
            Size = UDim2.fromScale(.8,.8),
            AnchorPoint = Vector2.new(.5,.5),

            Text = self.props.Text
        }, {
            UIStroke = Roact.createElement("UIStroke", {
                Color = Color3.fromHex("ffdd34"),
                Thickness = 5
            })
        }),
        Icon = self.props.Image and Roact.createElement("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(.5,.5),
            Size = UDim2.fromScale(.8,.8),
            AnchorPoint = Vector2.new(.5,.5),

            Image = self.props.Image
        }),
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(.4,0)
        }),
        AspectRatioConstraint = self.props.AspectRatio and Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = self.props.AspectRatio,
            [Roact.Ref] = self.AspectRatioRef
        })
    }

    for i,v in pairs(self.props[Roact.Children] or {}) do
        ChildrenTable[i] = v
    end

    local Button = Roact.createElement("TextButton", {
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = Color3.fromHex("ffffff"),
        TextTransparency = 1,
        Position = self.props.Position,
        Size = self.props.Size,
        AutoButtonColor = false,
        ZIndex = self.props.ZIndex,

        [Roact.Event.MouseButton1Click] = self.props.Callback,
        [Roact.Ref] = self.ButtonRef,

        [Roact.Event.MouseButton1Down] = function()
            UIEffects.Click()
            self:OnMouseButton1Down()
        end,
        [Roact.Event.MouseButton1Up] = function()
            self:OnMouseButton1Up()
        end,
        [Roact.Event.MouseEnter] = function()
            self:OnMouseEnter()
        end,
        [Roact.Event.MouseLeave] = function()
            self:Restore()
        end
    }, ChildrenTable)

    return Button
end

function CustomButton2:OnMouseButton1Down()
    local Squash = self.props.Squash or 14

    TweenService:Create(
        self.ButtonRef:getValue(),
        self.TweenInfo,
        {
            Size = self.OriginalProperties.Size - UDim2.fromOffset(Squash,Squash)
        }
    ):Play()
end

function CustomButton2:OnMouseButton1Up()
    self:OnMouseEnter()
end

function CustomButton2:didMount()
    local Button = self.ButtonRef:getValue()

    self.OriginalProperties = {
        Position = self.props.Position,
        Size = self.props.Size,
        BackgroundTransparency = Button.BackgroundTransparency,
    }
end

function CustomButton2:Restore()
    TweenService:Create(
        self.ButtonRef:getValue(),
        self.TweenInfo,
        self.OriginalProperties
    ):Play()
end

function CustomButton2:OnMouseEnter()
    local Offset = self.props.MouseEnterOffset or 10

    TweenService:Create(
        self.ButtonRef:getValue(),
        self.TweenInfo,
        {
            Size = self.OriginalProperties.Size + UDim2.fromOffset(Offset,Offset)
        }
    ):Play()
end

return CustomButton2