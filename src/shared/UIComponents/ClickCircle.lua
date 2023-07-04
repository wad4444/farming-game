local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local ClickCircle = Roact.Component:extend("ClickCircle")

function ClickCircle:init()
    self.CircleRef = Roact.createRef()
end

function ClickCircle:render()
    local CircleGui = Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true,
    }, {
        Circle = Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(.5, .5),
            Position = self.props.Position,
            Size = UDim2.fromOffset(50,50),
            BackgroundColor3 = Color3.fromHex("ffffff"),
    
            [Roact.Ref] = self.CircleRef
        }, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(1,0)
            }),
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1
            })
        })
    })

    return CircleGui
end

function ClickCircle:didMount()
    task.spawn(function()
        local Circle = self.CircleRef:getValue()

        local CircleTween = TweenService:Create(
            Circle,
            TweenInfo.new(.2),
            {
                Size = UDim2.fromOffset(Circle.Size.X.Offset * 1.5, Circle.Size.Y.Offset * 1.5),
                BackgroundTransparency = 1
            }
        )
    
        CircleTween:Play()
        CircleTween.Completed:Wait()
    
        if self.props.UnmountCallback then
            self.props.UnmountCallback()
        end
    end)
end

return ClickCircle