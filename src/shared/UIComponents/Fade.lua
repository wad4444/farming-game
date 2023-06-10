local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local Fade = Roact.Component:extend("Fade")

function Fade:init()
    self.FrameRef = Roact.createRef()
end

function Fade:render()
    local FadeFrame = Roact.createElement("Frame", {
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = Color3.fromHex("000000"),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10,
        Name = "Frame",

        [Roact.Ref] = self.FrameRef
    })

    local NewGui = Roact.createElement("ScreenGui", {
        ResetOnSpawn = true,
        IgnoreGuiInset = true,
        DisplayOrder = 10
    }, {
        Fading = FadeFrame
    })

    return NewGui
end

function Fade:didMount()
    coroutine.wrap(function()
        local Frame = self.FrameRef:getValue()

        local FadeIn = TweenService:Create(Frame, TweenInfo.new(
            self.props.Timestamps[1] or 1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        ), {
            BackgroundTransparency = 0
        })
    
        FadeIn:Play()
        FadeIn.Completed:Wait()
    
        task.wait(self.props.Timestamps[2])
    
        local FadeOut = TweenService:Create(Frame, TweenInfo.new(
            self.props.Timestamps[3] or 1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        ), {
            BackgroundTransparency = 1
        })
    
        FadeOut:Play()
        FadeOut.Completed:Wait()
    
        if not self.props.UnmountCallback then
            return
        end
    
        self.props.UnmountCallback()
    end)()
end

return Fade