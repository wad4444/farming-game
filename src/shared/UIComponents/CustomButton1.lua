local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Core = ReplicatedStorage:WaitForChild("Shared").Core 
local UIEffects = require(Core.UIEffects)

local Roact = require(Packages.Roact)

local CustomButton1 = Roact.Component:extend("CustomButton1")

function CustomButton1:init()
    self.ButtonRef = Roact.createRef()
    self.TweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear)
end

function CustomButton1:render()
    local ChildrenTable = {
        UICorner = Roact.createElement("UICorner",{
            CornerRadius = UDim.new(1,0)
        }),
        UIStroke = Roact.createElement("UIStroke",{
            Color = self.props.StrokeColor or Color3.fromHex("c22a2a"),
            Thickness = 3
        }),
        AspectRatio = self.props.AspectRatio and Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = self.props.AspectRatio
        }),
    }

    for i,v in pairs(self.props[Roact.Children] or {}) do
        ChildrenTable[i] = v
    end

    local NewButton = Roact.createElement("TextButton",{
        Name = self.props.Name,
        TextScaled = true,
        BackgroundColor3 = self.props.BackgroundColor3 or Color3.fromHex("ff0000"),
        TextColor3 = Color3.fromHex("ffffff"),
        AnchorPoint = Vector2.new(.5,.5),
        AutoButtonColor = false,
        Text = self.props.Text,
        Font = self.props.Font or Enum.Font.FredokaOne,
        ZIndex = self.props.ZIndex,
        
        Position = self.props.Position,
        Size = self.props.Size,

        [Roact.Ref] = self.ButtonRef,
        [Roact.Event.MouseEnter] = function()
            if self.props.CanTween then
                if not self.props.CanTween() then
                    return
                end
            end
            
            self:OnMouseEnter()
        end,
        [Roact.Event.MouseLeave] = function()
            if self.props.CanTween then
                if not self.props.CanTween() then
                    return
                end
            end

            self:OnMouseLeave()
        end,
        [Roact.Event.MouseButton1Down] = function()
            UIEffects.Click()
        end,
        [Roact.Event.MouseButton1Click] = self.props.Callback
    }, ChildrenTable)

    return NewButton
end

function CustomButton1:didMount()
    local Button = self.ButtonRef:getValue()

    self.OriginalProperties = {
        Size = self.props.Size,
        BackgroundTransparency = Button.BackgroundTransparency,
        BackgroundColor3 = Button.BackgroundColor3
    }
end

function CustomButton1:OnMouseLeave()
    TweenService:Create(
        self.ButtonRef:getValue(),
        self.TweenInfo,
        self.OriginalProperties
    ):Play()
end

function CustomButton1:OnMouseEnter()
    local Hue, Saturation, Value = self.OriginalProperties.BackgroundColor3:ToHSV()

    TweenService:Create(
        self.ButtonRef:getValue(),
        self.TweenInfo,
        {
            Size = self.OriginalProperties.Size + UDim2.fromOffset(5,5),
            BackgroundColor3 = Color3.fromHSV(Hue,Saturation,Value - Value/(self.props.ColorChangeFactor or 15))
        }
    ):Play()
end

return CustomButton1