local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local UIComponents = script.Parent
local CustomButton1 = require(UIComponents.CustomButton1)

local BaseFrame1 = Roact.Component:extend("BaseFrame1")

function BaseFrame1:init()
    if self.props.__GET then
        self.props.__GET(self)
    end

    self.MainFrameRef = Roact.createRef()
end

function BaseFrame1:render()
    local ChildrenTable = {
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(.05, 0)
        }),
        UIStroke = Roact.createElement("UIStroke", {
            Thickness = 8,
            Color = Color3.fromHex("ffdd34"),
        }),
        Texture = Roact.createElement("ImageLabel", {
            Name = "Texture",
            Image = "rbxassetid://13606808259",
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            ImageTransparency = .9,
        }),
    }

    for i,v in pairs(self.props[Roact.Children]) do
        ChildrenTable[i] = v
    end

    local Frame = Roact.createElement("Frame", {
        Position = self.props.Position,
        Size = self.props.Size,
        Name = "Frame",
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = Color3.fromHex("ffffff"),
        Visible = false,
        ZIndex = self.props.ZIndex,

        [Roact.Ref] = self.MainFrameRef
    }, ChildrenTable)

    return Frame
end

function BaseFrame1:Close()
    local MainFrame = self.MainFrameRef:getValue()
    MainFrame.Visible = false
end

function BaseFrame1:Open()
    local MainFrame = self.MainFrameRef:getValue()

    MainFrame.Visible = true
    MainFrame.Position = self.props.Position + UDim2.fromOffset(0, 100)

    local OpenTween = TweenService:Create(MainFrame, TweenInfo.new(.3, Enum.EasingStyle.Back), {
        Position = self.props.Position
    })

    OpenTween:Play()
    OpenTween.Completed:Wait()
end

function BaseFrame1:didMount()
    if self.props.OpenOnMount then
        self:Open()
    end
end

return BaseFrame1