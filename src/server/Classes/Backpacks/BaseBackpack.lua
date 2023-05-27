local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local PacksPool = Assets.Backpacks

local Backpack = {}
Backpack.__index = Backpack

local DefaultSettings = {
    Type = "Backpack1",
    Upgrades = {},
}

function Backpack.GetSettings()
    return table.clone(DefaultSettings)
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
    local OriginalModel = PacksPool:FindFirstChild(self.Settings.Type)
    local Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")

    local NewPack = OriginalModel:Clone()
    NewPack.Parent = Character
    Humanoid:AddAccessory(NewPack)

    self.PackInstance = NewPack
end

function Backpack:GetInfo()
    return {
        CLASS_NAME = self.Type,
        Upgrades = {}
    }
end

return Backpack