local CollectionService = game:GetService("CollectionService")
local HitboxTracker = {}
HitboxTracker.__index = HitboxTracker

local DefaultConfig = {
    HitboxInfo = {
        Start = Vector3.new(2,2,2),
        End = Vector3.new(2,2,2)
    },
    CenterDistance = 5,
    MaxPartsPerDetection = math.huge
}

function HitboxTracker.new(...)
    local self = setmetatable({}, HitboxTracker)

    return self:Constructor(...) or self
end

function HitboxTracker.GetConfig()
    return table.clone(DefaultConfig)
end

function HitboxTracker:Constructor(Tool, Config)
    self.Tool = Tool
    self.Config = {}

    for i,v in pairs(DefaultConfig) do
        self.Config[i] = Config[i] or v
    end
end

function HitboxTracker:Track()
    local Player = self.Tool.Player.Instance
    local Character = Player.Character

    if not Character then
        return {}
    end

    local RootPartCFrame = Character.PrimaryPart.CFrame
    local Center = (RootPartCFrame + RootPartCFrame.LookVector * self.Config.CenterDistance).Position
    local HitboxInfo = self.Config.HitboxInfo

    local HitboxRegion = Region3.new(Center - HitboxInfo.Start, Center + HitboxInfo.End)

    local OverlapParameters = OverlapParams.new()
    OverlapParameters.FilterDescendantsInstances = {self.Tool.ToolInstance, Character}
    OverlapParameters.FilterType = Enum.RaycastFilterType.Exclude

    local Parts = game.Workspace:GetPartBoundsInBox(HitboxRegion.CFrame, HitboxRegion.Size, OverlapParameters)

    return Parts or {}
end

function HitboxTracker:TrackCrops()
    local Parts = self:Track()
    local ValidCrops = {}

    for i,v in pairs(Parts) do
        local IsCrop = CollectionService:HasTag(v, "Crop") and v.Transparency < 1
        if IsCrop then
            table.insert(ValidCrops, v)
        end
    end

    return ValidCrops
end

return HitboxTracker