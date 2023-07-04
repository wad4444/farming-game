local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFXPool = Assets.VFXPool
local VFXAssets = VFXPool.CoinDrop

local Trashcan = game.Workspace.Trashcan

function Lerp(a, b, c)
    return a + (b - a) * c
end

function QuadBezier(Time, p0, p1, p2)
    local L1 = Lerp(p0, p1, Time)
    local L2 = Lerp(p1, p2, Time)

    return Lerp(L1, L2, Time)
end

function DropCoin(P1, P2, P3)
    local Speed = 2.5
    local RotationSpeed = 5
    local HeightDifference = .0325

    local NewCoin = VFXAssets.Coin:Clone()
    NewCoin.Parent = Trashcan

    for I = 0, 1, 0.035 do
        NewCoin.Position = QuadBezier(I, P1, P2, P3)
        RunService.Heartbeat:Wait()
    end

    task.delay(3, function()
        TweenService:Create(NewCoin, TweenInfo.new(.5), {
            Transparency = 1
        }):Play()
        
        Debris:AddItem(NewCoin, .5)
    end)

    local CosAngle = 0
    while NewCoin do
        RunService.RenderStepped:Wait()

        local CurrentCFrame = NewCoin:GetPivot()
        local NewCFrame = CurrentCFrame + Vector3.new(0,HeightDifference * math.cos(math.rad(CosAngle)),0)

        NewCoin:PivotTo(NewCFrame * CFrame.Angles(0,math.rad(RotationSpeed),0))

        CosAngle += Speed
    end
end

return function(Character)
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local RootAttachment = HumanoidRootPart.RootAttachment

    local CharSize = Character:GetExtentsSize()

    for i = 1,math.random(3, 4) do
        local Distance = math.random(50,80)/10
        local RandomLookVector = (HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(math.random(1, 360)),0)).LookVector

        local Point1 = HumanoidRootPart.Position
        local Point2 = (HumanoidRootPart.CFrame + RandomLookVector * Distance - Vector3.new(0, CharSize.Y/2 - VFXAssets.Coin.Size.Y * 1.75, 0)).Position
        local Point3 = (HumanoidRootPart.CFrame + RandomLookVector * Distance/2 + Vector3.new(0, CharSize.Y, 0)).Position

        task.spawn(DropCoin, Point1, Point3, Point2)
    end
end