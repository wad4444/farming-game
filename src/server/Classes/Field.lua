local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

local Field = {}
Field.__index = Field

Field.DefaultSettings = {
    CropType = "Wheat",
    CropRespawnTime = NumberRange.new(10,15),
    CropDropAmount = NumberRange.new(1,3),
    CropSize = Vector2.new(3,3),
    MaxCrops = nil
}
Field.InstanceToWrap = {}

function ConvertRange(Value)
    if typeof(Value ~= "NumberRange") then
        return Value
    end

    return math.random(Value.Min, Value.Max)
end

function GetFullDivided(Number, DivideBy)
    return Number / DivideBy - Number % DivideBy
end

function Field.getSettings()
    return table.clone(Field.DefaultSettings)
end

function Field.get(Instance)
    return Field.InstanceToWrap[Instance]
end

function Field.new(Instance, ...)
    local self = setmetatable({}, Field)
    Field.InstanceToWrap[Instance] = self
    return self:Constructor(Instance, ...) or self
end

function Field:Constructor(FieldInstance, Settings)
    for i,v in pairs(Field.DefaultSettings) do
        Settings[i] = Settings[i] or v
        self[i] = Settings[i]
    end

    self.Splitted = not FieldInstance:IsA("BasePart")
    self.Instance = FieldInstance
end

function Field:NewCropExample(Position)
    if not self.Initialized then
        return
    end

    if self.MaxCrops and #self.Crops >= self.MaxCrops then
        return
    end

    local CropModel = Assets.Crops:FindFirstChild(self.CropType)
    local EndPivot = CFrame.new(Position + Vector3.new(0,CropModel.Size.Y/2,0))

    local ClonedModel = CropModel:Clone()
    ClonedModel.CFrame = EndPivot
    ClonedModel.Parent = self.Instance.Crops

    table.insert(self.Crops, ClonedModel)
end

function Field:Initialize()
    if not self.Instance or self.Initialized then
        return
    end
    
    local CropsFolder = Instance.new("Folder", self.Instance)
    CropsFolder.Name = "Crops"

    self.Crops = {}
    self.Initialized = true

    if not self.Splitted then
        local Start = self.Instance.Position - self.Instance.Size/2
        Start = Vector3.new(Start.X, self.Instance.Position.Y + self.Instance.Size.Y/2, Start.Z)

        local XIterations = GetFullDivided(self.Instance.Size.X, self.CropSize.X)
        local ZIterations = GetFullDivided(self.Instance.Size.Z, self.CropSize.Y)

        for i = 1, XIterations do
            local CurrentPos = Start + Vector3.new(self.CropSize.X * i,0,0)

            for x = 1, ZIterations do
                local CropPosition = CurrentPos + Vector3.new(0,0,self.CropSize.Y * x)
                self:NewCropExample(CropPosition)
            end
        end
    end
end

return Field