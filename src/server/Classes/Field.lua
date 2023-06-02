local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes

local Classes = script.Parent
local PlayerWrap = require(Classes.PlayerWrap)

local Field = {}
Field.__index = Field

Field.DefaultSettings = {
    CropType = "Wheat",
    CropRespawnTime = NumberRange.new(10,15),
    CropDropAmount = NumberRange.new(1,2),
    CropOffset = Vector3.new(0,0,0),
    MaxCrops = nil
}
Field.InstanceToWrap = {}

function ConvertRange(Value)
    if typeof(Value) ~= "NumberRange" then
        return Value
    end

    return math.random(Value.Min, Value.Max)
end

function Field.GetSettings()
    return table.clone(Field.DefaultSettings)
end

function Field.Get(Instance)
    return Field.InstanceToWrap[Instance]
end

function Field.new(Instance, ...)
    local self = setmetatable({}, Field)
    Field.InstanceToWrap[Instance] = self
    
    return self:Constructor(Instance, ...) or self
end

function Field:Constructor(FieldInstance, Settings)
    self.Settings = {}

    for i,v in pairs(Field.DefaultSettings) do
        self.Settings[i] = Settings[i] or v
    end

    self.Splitted = not FieldInstance:IsA("BasePart")
    self.Instance = FieldInstance
    self.CropModel = Assets.Crops:FindFirstChild(self.Settings.CropType)
end

function Field:NewCropExample(Position)
    if not self.Initialized then
        return
    end

    if self.Settings.MaxCrops and #self.Crops >= self.Settings.MaxCrops then
        return
    end

    local EndPivot = CFrame.new(Position + Vector3.new(0,self.CropModel.Size.Y/2,0))

    local ClonedModel = self.CropModel:Clone()
    ClonedModel.CFrame = EndPivot
    ClonedModel.Parent = self.Instance.Crops

    CollectionService:AddTag(ClonedModel, "Crop")

    table.insert(self.Crops, ClonedModel)
end

function Field:Initialize()
    if not self.Instance or self.Initialized then
        return
    end
    
    local CropsModel = Instance.new("Model", self.Instance)
    CropsModel.Name = "Crops"

    local Settings = self.Settings

    self.Crops = {}
    self.Initialized = true

    if not self.Splitted then
        local FieldPosition, FieldSize = self.Instance.Position, self.Instance.Size
        local Start = FieldPosition - Vector3.new(FieldSize.X/2,0,FieldSize.Z/2)
        local CropSize = self.CropModel.Size

        for x = 0, FieldSize.X, CropSize.X + Settings.CropOffset.X do
            for z = 0, FieldSize.Z, CropSize.Z + Settings.CropOffset.Z do
                self:NewCropExample(Start + Vector3.new(x,0,z))
            end
        end
    end

    local ModelSize = CropsModel:GetExtentsSize()
    CropsModel:PivotTo(self.Instance.CFrame + Vector3.new(0,ModelSize.Y/2,0))
end

function Field:BreakCrops(Player, Crops)
    Crops = typeof(Crops) ~= "table" and {Crops} or Crops

    local DropSumm = 0
    for i,v in pairs(Crops) do
        DropSumm += ConvertRange(self.Settings.CropDropAmount)
    end

    local PlayerBackpack = Player:GetEquippedBackpack()
    local IsEnoughSpace = Player.Calculations:CanIncrementWithCapacity(
        {"Crops", self.Settings.CropType},
        DropSumm,
        PlayerBackpack.Settings.Capacity
    )

    if not IsEnoughSpace then
        local Difference = Player.Calculations:DifferenceFromCapacity(
            {"Crops", self.Settings.CropType},
            PlayerBackpack.Settings.Capacity
        )

        if Difference <= 0 then
            return
        end

        DropSumm = Difference
    end

    Player.Calculations:IncrementWithCapacity(
        {"Crops", self.Settings.CropType},
        DropSumm,
        PlayerBackpack.Settings.Capacity
    )

    Remotes.CastEffect:FireAllClients("BreakCrops",Crops)

    for i,v in pairs(Crops) do
        if not CollectionService:HasTag(v, "Crop") then
            continue
        end

        local RespawnTime = ConvertRange(self.Settings.CropRespawnTime)

        v.Transparency = 1
        CollectionService:RemoveTag(v, "Crop")
        CollectionService:RemoveTag(v, "ReadyToSpawn")

        task.delay(RespawnTime,function()
            CollectionService:AddTag(v, "ReadyToSpawn")

            task.wait(.5)

            CollectionService:AddTag(v, "Crop")
            v.Transparency = 0
        end)
    end

    return true
end

return Field