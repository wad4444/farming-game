local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

local Field = {}
Field.__index = Field

Field.DefaultSettings = {
    CropType = "Wheat",
    CropRespawnTime = NumberRange.new(10,15),
    CropDropAmount = NumberRange.new(1,3),
    CropOffset = Vector2.new(0,0),
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
    return (Number / DivideBy) - math.fmod(Number, DivideBy)
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
    self.CropModel = Assets.Crops:FindFirstChild(self.CropType)
end

function Field:NewCropExample(Position)
    if not self.Initialized then
        return
    end

    if self.MaxCrops and #self.Crops >= self.MaxCrops then
        return
    end

    local EndPivot = CFrame.new(Position + Vector3.new(0,self.CropModel.Size.Y/2,0))

    local ClonedModel = self.CropModel:Clone()
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
        local FieldPosition, FieldSize = self.Instance.Position, self.Instance.Size
        local Start = FieldPosition - Vector3.new(FieldSize.X/2,0,FieldSize.Z/2)
        local CropSize = self.CropModel.Size

        local XIterations = GetFullDivided(FieldSize.X, CropSize.X)
        local ZIterations = GetFullDivided(FieldSize.Z, CropSize.Z)

        for x = 1, XIterations do
            local CurrentX = Start + Vector3.new(CropSize.X * x + self.CropOffset.X * x, 0, 0)
            for z = 1, ZIterations do
                local Current = CurrentX + Vector3.new(0, 0, CropSize.Z * z + self.CropOffset.Z * z)
                self:NewCropExample(Current)
            end
        end
    end
end

return Field