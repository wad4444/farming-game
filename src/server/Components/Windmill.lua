local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Components)

local Windmill = Component.new({Tag = "Windmill"})

function Windmill:Construct()
    self.Tick = .5
end

function Windmill:Start()
    local SpinningPart = self.Instance.PrimaryPart or self.Instance:FindFirstChild("Windmill")

    while true do
        if not SpinningPart then
            task.wait()
            continue
        end

        SpinningPart.CFrame = SpinningPart.CFrame * CFrame.Angles(math.rad(self.Tick),0,0)
        RunService.Heartbeat:Wait()
    end
end

return Windmill