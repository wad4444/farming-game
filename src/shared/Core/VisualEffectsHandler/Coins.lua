local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFXPool = Assets.VFXPool
local VFXAssets = VFXPool.CropSpawn

return function (Character)
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local RootAttachment = HumanoidRootPart.RootAttachment

        
end