local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFXPool = Assets.VFXPool
local VFXAssets = VFXPool.CropSpawn

local Trashcan = game.Workspace.Trashcan

return function(Crop)
    local AppearTween = TweenService:Create(Crop, TweenInfo.new(.5), {
        Transparency = 0
    })

    AppearTween:Play()
    
    task.wait(.4)

    local NewEmitter = VFXAssets.Stars:Clone()
    NewEmitter.Parent = Crop
    NewEmitter:Emit(NewEmitter:GetAttribute("EmitCount") or 2)

    Debris:AddItem(NewEmitter,1)
end