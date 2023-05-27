local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFXPool = Assets.VFXPool

local VFXAssets = VFXPool.BreakCrops
local Lifetime = 2

local AttachmentCFrame = CFrame.new(0,-3,0)

return function(Crops)
    local ClonedCrops = {}
    
    for i,v in pairs(Crops) do
        table.insert(ClonedCrops,v:Clone())
    end

    local DebrisPool = {}
    local Emitters = {}

    for i,Crop in pairs(ClonedCrops) do
        local LeafAttachment = Instance.new("Attachment", Crop)
        LeafAttachment.CFrame = AttachmentCFrame

        do
            local ClonedLeaf = VFXAssets.Leaf:Clone()
            ClonedLeaf.Parent = LeafAttachment
    
            local ClonedWheat = VFXAssets.Wheat:Clone()
            ClonedWheat.Parent = Crop

            Debris:AddItem(ClonedLeaf, Lifetime)
            Debris:AddItem(ClonedWheat, Lifetime)
        end

        local Bottom = Crop.CFrame - Vector3.new(0,Crop.Size.Y/2,0)
        local EndCFrame = (Bottom + Bottom.LookVector * Crop.Size.Y/2) * CFrame.Angles(0,math.rad(90),0)

        local Tween = TweenService:Create(Crop, TweenInfo.new(.8), {
            CFrame = EndCFrame
        })
        Tween:Play()

        Debris:AddItem(Crop, Lifetime)
    end

    for i,v in pairs(Emitters) do
        v:Emit(v:GetAttribute("EmitCount") or 0)
    end
end