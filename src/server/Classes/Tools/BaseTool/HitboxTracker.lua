local CollectionService = game:GetService("CollectionService")
local HitboxTracker = {}
HitboxTracker.__index = HitboxTracker

local DefaultSettings = {
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

function HitboxTracker.GetSettings()
    return table.clone(DefaultSettings)
end

function HitboxTracker:Constructor(Tool, Settings)
    self.Tool = Tool
    self.Settings = {}

    for i,v in pairs(DefaultSettings) do
        self.Settings[i] = Settings[i] or v
    end
end

function HitboxTracker:Track()
    local Player = self.Tool.Player
    local Character = Player.Character

    if not Character then
        return {}
    end

    local RootPartCFrame = Character.PrimaryPart.CFrame
    local Center = (RootPartCFrame + RootPartCFrame.LookVector * self.Settings.CenterDistance).Position
    local HitboxInfo = self.Settings.HitboxInfo

    local HitboxRegion = Region3.new(Center - HitboxInfo.Start, Center + HitboxInfo.End)

    local OverlapParameters = OverlapParams.new()
    OverlapParameters.FilterDescendantsInstances = {self.Tool.ToolInstance, Character}
    OverlapParameters.FilterType = Enum.RaycastFilterType.Exclude

    local Parts = game.Workspace:GetPartBoundsInBox(HitboxRegion.CFrame, HitboxRegion.Size, OverlapParameters)

    return Parts or {}
end

function HitboxTracker:TrackCrops()
    local Parts = self:Track()

    for i,v in pairs(Parts) do
        local IsCrop = CollectionService:HasTag(v, "Crop")
        if not IsCrop then
            table.remove(Parts,i)
        end
    end

    return Parts
end

return HitboxTracker