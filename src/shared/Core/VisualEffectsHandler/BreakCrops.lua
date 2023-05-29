local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFXPool = Assets.VFXPool

local Trashcan = game.Workspace.Trashcan

local VFXAssets = VFXPool.BreakCrops
local Lifetime = 2

local AttachmentCFrame = CFrame.new(0,-3,0)

return function(Crops)
    local ClonedCrops = {}
    
    for i,v in pairs(Crops) do
        local Clone = v:Clone()
        Clone.Parent = Trashcan
        table.insert(ClonedCrops,Clone)
    end

    local DebrisPool = {}
    local Emitters = {}

    for i,Crop in pairs(ClonedCrops) do
        local LeafAttachment = Instance.new("Attachment", Crop)
        LeafAttachment.CFrame = AttachmentCFrame

        local ClonedEmitters = {}

        for i,v in pairs(VFXAssets:GetChildren()) do
            local Cloned = v:Clone()
            Cloned.Parent = Crop
            
            ClonedEmitters[v.Name] = Cloned
        end

        Emitters = ClonedEmitters
        ClonedEmitters.Leaf.Parent = LeafAttachment

        local IsReversed = math.random(0,1) == 0 and true or false

        local Bottom = Crop.CFrame - Vector3.new(0,Crop.Size.Y/2,0)
        local EndCFrame = (Bottom + (IsReversed and Bottom.LookVector or Bottom.RightVector) * Crop.Size.Y/2) * 
        (IsReversed and CFrame.Angles(0,0,math.rad(90)) or CFrame.Angles(math.rad(90),0,0))

        local Tween = TweenService:Create(Crop, TweenInfo.new(.4), {
            CFrame = EndCFrame,
            Transparency = 1
        })
        Tween:Play()

        Debris:AddItem(Crop, Lifetime)
    end

    for i,v in pairs(Emitters) do
        v:Emit(v:GetAttribute("EmitCount") or 0)
        Debris:AddItem(v,Lifetime)
    end
end