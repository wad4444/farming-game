local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Core = Shared.Core
local Packages = ReplicatedStorage:WaitForChild("Packages")

local UIComponents = require(Shared.UIComponents)
local Roact = require(Packages.Roact)
local UIEffects = require(Core.UIEffects)

function ToggleCharactersVisiblity(Toggled)
    for i,v in pairs(Players:GetPlayers()) do
        local Character = v.Character

        if not Character then
            continue
        end

        Character.Parent = Toggled and workspace or nil
    end
end

return function(Shop, FinishedCallback)
    local Camera = game.Workspace.CurrentCamera
    Camera.CameraType = Enum.CameraType.Scriptable

    local Scriptable = Shop.Instance:WaitForChild("Scriptable")
    local DoorOffset = 5

    ToggleCharactersVisiblity(false)

    local CameraPoints = {}
    for i,v in pairs(Scriptable:GetChildren()) do
        if not string.match(v.Name, "CameraPoint") then
            continue
        end

        local Index = string.match(v.Name, "%d")
        CameraPoints[tonumber(Index)] = v
    end

    local function MoveDoor(Door, Direction)
        local EndCFrame = Door:GetPivot() + Direction * DoorOffset

        local CFrameValue = Instance.new("CFrameValue", Door) do
            CFrameValue.Value = Door:GetPivot()

            CFrameValue.Changed:Connect(function(Value)
                Door:PivotTo(Value)
            end)
        end

        local Tween = TweenService:Create(CFrameValue, TweenInfo.new(
            1.35,
            Enum.EasingStyle.Quad
        ), {Value = EndCFrame})

        Tween:Play()
    end

    local function SetCamera(Destination)
        Destination = typeof(Destination) == "Instance" and Destination.CFrame or Destination

        Camera.CFrame = Destination
    end

    local function MoveCamera(Destination, Time)
        Destination = typeof(Destination) == "Instance" and Destination.CFrame or Destination

        local Tween = TweenService:Create(Camera,TweenInfo.new(
            Time or 1,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.In
        ), {CFrame = Destination})
        Tween:Play()
    end

    SetCamera(CameraPoints[1])

    task.wait(.5)

    task.spawn(UIEffects.Fade,1,1,1)

    MoveDoor(Scriptable.Door1, -Scriptable.Door1:GetPivot().RightVector)
    MoveDoor(Scriptable.Door2, Scriptable.Door2:GetPivot().RightVector)

    MoveCamera(CameraPoints[2])

    task.wait(2)

    ToggleCharactersVisiblity(true)

    if FinishedCallback then
        FinishedCallback()
    end
end