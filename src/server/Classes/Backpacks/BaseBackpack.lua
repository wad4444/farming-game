local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local PacksPool = Assets.Backpacks

local Backpack = {}
Backpack.__index = Backpack

local DefaultSettings = {
    Type = "Backpack1",
    Upgrades = {},
    Capacity = 40
}

function RoundToWhole(Number)
    return math.floor(Number) + .5
end

function Backpack.GetSettings()
    return table.clone(DefaultSettings)
end

function Backpack.new(...)
    local self = setmetatable({}, Backpack)
    return self:Constructor(...) or self
end

function Backpack:Constructor(Player, ToolSettings)
    self.Player = Player
    self.Settings = {}
    
    for i,v in pairs(DefaultSettings) do
        self.Settings[i] = ToolSettings[i] or v
    end
end

function Backpack:Unload()
    if not self.PackInstance then
        return
    end

    self.PackInstance:Destroy()
end

function Backpack:Initialize()
    if self.PackInstance then
        self.PackInstance:Destroy()
    end

    local OriginalModel = PacksPool:FindFirstChild(self.Settings.Type)
    local Character = self.Player.Instance.Character or self.Player.Instance.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    local NewPack = OriginalModel:Clone()
    NewPack.Parent = Character
    Humanoid:AddAccessory(NewPack)

    self.PackInstance = NewPack
end

function Backpack:CropAmountChanged(CropName, Amount)
    --[[if not self.PackInstance then
        return
    end

    local Visuals = self.PackInstance:FindFirstChild(CropName)
    local CropAmount = self.Player.Calculations:Get({"Crops",CropName})

    if not Visuals then
        return
    end

    local Capacity = self.Settings.Capacity
    local AllObjects = Visuals:GetChildren()

    local HowMuchFilled = Capacity / CropAmount
    local CropsAmountToMakeVisible = #AllObjects / HowMuchFilled]]
end

function Backpack:GetInfo()
    local Info = {}

    for i,v in pairs(DefaultSettings) do
        local IsDefault = self[i] == v
        Info[i] = not IsDefault and self[i] or nil
    end

    return Info
end

return Backpack