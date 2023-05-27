local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFXPool = Assets.VFXPool
local VFXAssets = VFXPool.CropSpawn

local Trashcan = game.Workspace.Trashcan

return function(Crop)
    task.wait(.45)

    local NewEmitter = VFXAssets.Stars:Clone()
    NewEmitter.Parent = Crop
    NewEmitter:Emit(NewEmitter:GetAttribute("EmitCount") or 2)

    Debris:AddItem(NewEmitter,1)
end