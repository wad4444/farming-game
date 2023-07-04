local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Classes = script.Parent
local SharedPackages = ReplicatedStorage.Packages
local ItemsData = require(ReplicatedStorage.Shared.DataStructures.ItemsData)

local Calculations = require(Classes.Calculations)
local PurchaseHandler = require(Classes.PurchaseHandler)
local ReplicaService = require(SharedPackages.Replica)

local PlayerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")

local PlayerWrap = {}
PlayerWrap.__index = PlayerWrap

local InstanceToWrap = {}

function GetAnimationInstanceByName(AnimationName)
    local AnimationInstance = Assets.Animations:FindFirstChild(AnimationName)

    if not AnimationInstance then
        return
    end

    return AnimationInstance
end

function PlayerWrap.new(Instance, ...)
    local self = setmetatable({}, PlayerWrap)
    InstanceToWrap[Instance] = self
    
    return self:Constructor(Instance, ...) or self
end

function PlayerWrap.get(Instance)
    return InstanceToWrap[Instance]
end

function PlayerWrap:PlayAnimation(AnimationName)
    local Character = self.Instance.Character

    if not Character then
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Animator = Humanoid:WaitForChild("Animator")

    local HitAnimation = GetAnimationInstanceByName(AnimationName)

    if not HitAnimation then
        return
    end

    local AnimationTrack = Animator:LoadAnimation(HitAnimation)
    AnimationTrack:Play()
end

function PlayerWrap:Constructor(Instance, Profile)
    self.Instance = Instance
    self.Profile = Profile

    self.Replica = ReplicaService.NewReplica({
        ClassToken = PlayerProfileClassToken,
        Replication = Instance,
        Data = Profile.Data
    })

    self.Equipped = {}

    for i,v in pairs(Profile.Data.Equipped) do
        local Config = ItemsData[v]

        local BaseClass = Classes:FindFirstChild(Config.Core)
        BaseClass = BaseClass and require(BaseClass)

        if not BaseClass then
            return
        end

        local NewClass = BaseClass.new(self, Config)
        NewClass:Initialize()

        self.Equipped[i] = NewClass
    end

    self.Calculations = Calculations.new(self)
    self.PurchaseHandler = PurchaseHandler.new(self)
end

function PlayerWrap:GetEquippedBackpack()
    return self.Equipped.Backpack
end

function PlayerWrap:GetEquippedTool()
    return self.Equipped.Tool
end

function PlayerWrap:AddItem(ItemID)
    if not ItemsData[ItemID] then
        return
    end

    self.Replica:ArrayInsert({"Items"}, ItemID)
end

function PlayerWrap:RemoveItem(ItemID)
    local ItemIndex = table.find(self.Profile.Data.Items, ItemID)

    if not ItemIndex then
        return
    end

    self.Replica:ArrayRemove(self.Profile.Data.Items, ItemIndex)
end

function PlayerWrap:HasItem(ItemID)
    return table.find(self.Profile.Data.Items, ItemID) and true or false
end

function PlayerWrap:EquipItem(ItemID)
    if not self:HasItem(ItemID) then
        return
    end

    local ItemInfo = ItemsData[ItemID]
    
    if not ItemInfo then
        return
    end

    local Type = ItemInfo.Type
    local CoreName = ItemInfo.Core
    ItemInfo.ID = ItemID

    local CurrentlyEquipped = self.Equipped[Type]
    if CurrentlyEquipped.ID == ItemID then
        return
    end

    CurrentlyEquipped:Unload()

    local CoreModule = Classes:FindFirstChild(CoreName)
    CoreModule = CoreModule and require(CoreModule)

    if not CoreModule then
        return
    end

    local NewClass = CoreModule.new(self, ItemInfo)
    NewClass:Initialize()

    self.Equipped[Type] = NewClass
    self.Replica:ArraySet({"Equipped"}, Type, ItemID)
end

return PlayerWrap