local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerScriptService.Server

local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes
local Packages = ReplicatedStorage.Packages

local Component = require(Packages.Components)

local Classes = ServerModules.Classes
local PlayerWrap = require(Classes.PlayerWrap)

local Field = Component.new({Tag = "Field"})

local Config = {
    CropType = "Wheat",
    CropRespawnTime = NumberRange.new(10,15),
    CropDropAmount = NumberRange.new(1,2),
    CropOffset = Vector3.new(0,0,0),
    MaxCrops = nil
}

function ConvertRange(Value)
    if typeof(Value) ~= "NumberRange" then
        return Value
    end

    return math.random(Value.Min, Value.Max)
end

function Field:Construct()
    self.Config = {}

    for i,v in pairs(Config) do
        self.Config[i] = self.Instance:GetAttribute(i) or v
    end

    self.Splitted = not self.Instance:IsA("BasePart")
    self.CropModel = Assets.Crops:FindFirstChild(self.Config.CropType)
end

function Field:NewCropExample(Position)
    if not self.Initialized then
        return
    end

    if self.Config.MaxCrops and #self.Crops >= self.Config.MaxCrops then
        return
    end

    local EndPivot = CFrame.new(Position + Vector3.new(0,self.CropModel.Size.Y/2,0))

    local ClonedModel = self.CropModel:Clone()
    ClonedModel.CFrame = EndPivot
    ClonedModel.Parent = self.Instance.Crops

    CollectionService:AddTag(ClonedModel, "Crop")

    table.insert(self.Crops, ClonedModel)
end

function Field:Start()
    if not self.Instance or self.Initialized then
        return
    end
    
    local CropsModel = Instance.new("Model", self.Instance)
    CropsModel.Name = "Crops"

    local Config = self.Config

    self.Crops = {}
    self.Initialized = true

    if not self.Splitted then
        local FieldPosition, FieldSize = self.Instance.Position, self.Instance.Size
        local Start = FieldPosition - Vector3.new(FieldSize.X/2,0,FieldSize.Z/2)
        local CropSize = self.CropModel.Size

        for x = 0, FieldSize.X, CropSize.X + Config.CropOffset.X do
            for z = 0, FieldSize.Z, CropSize.Z + Config.CropOffset.Z do
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
        DropSumm += ConvertRange(self.Config.CropDropAmount)
    end

    local PlayerBackpack = Player:GetEquippedBackpack()
    local IsEnoughSpace = Player.Calculations:CanIncrementWithCapacity(
        {"Crops", self.Config.CropType},
        DropSumm,
        PlayerBackpack.Config.Capacity
    )

    if not IsEnoughSpace then
        local Difference = Player.Calculations:DifferenceFromCapacity(
            {"Crops", self.Config.CropType},
            PlayerBackpack.Config.Capacity
        )

        if Difference <= 0 then
            return
        end

        DropSumm = Difference
    end

    Player.Calculations:IncrementWithCapacity(
        {"Crops", self.Config.CropType},
        DropSumm,
        PlayerBackpack.Config.Capacity
    )

    Remotes.CastEffect:FireAllClients("BreakCrops",Crops)

    for i,v in pairs(Crops) do
        if not CollectionService:HasTag(v, "Crop") then
            continue
        end

        local RespawnTime = ConvertRange(self.Config.CropRespawnTime)

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