local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Components)

local SpinningPart = Component.new({Tag = "SpinningPart"})

function SpinningPart:Construct()
    self.Speed = 2.5
    self.RotationSpeed = 2
    self.HeightDifference = .0325
    self.CosAngle = 0
    self.Enabled = true
end

function SpinningPart:Toggle(IsEnabled)
    self.Enabled = IsEnabled
end

function SpinningPart:HeartbeatUpdate()
    if not self.Enabled then
        return
    end

    local CurrentCFrame = self.Instance:GetPivot()
    local NewCFrame = CurrentCFrame + Vector3.new(0,self.HeightDifference * math.cos(math.rad(self.CosAngle)),0)

    self.Instance:PivotTo(NewCFrame * CFrame.Angles(0,math.rad(self.RotationSpeed),0))

    self.CosAngle += self.Speed
end

return SpinningPart