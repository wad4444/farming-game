local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Classes = script.Parent
local SharedPackages = ReplicatedStorage.Packages

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

    self.Items = {}

    for _, ItemInfo in pairs(Profile.Data.Items) do
        local CoreName = ItemInfo.Core

        if not CoreName then
            continue
        end

        local CoreClass = require(Classes:FindFirstChild(CoreName))

        local Item = CoreClass.new(self, ItemInfo)
        table.insert(self.Items, Item)
    end

    self.Calculations = Calculations.new(self)
    self.PurchaseHandler = PurchaseHandler.new(self)
end

function PlayerWrap:GetEquippedBackpack()
    return self.Backpacks[self.Profile.Data.Equipped.Backpack]
end

function PlayerWrap:GetEquippedTool()
    return self.Tools[self.Profile.Data.Equipped.Tool]
end

function PlayerWrap:Initialize()
    local Profile = self.Profile

    local function InitializeEquipped(Field)
        local Index = Profile.Data.Equipped[Field]

        if not Index then
            return
        end

        local Tool = self.Items[Index]

        if not Tool then
            return
        end

        Tool:Initialize()
    end

    if not self.Instance.Character then
        self.Instance.CharacterAdded:Wait()
    end

    InitializeEquipped("Tool")
    InitializeEquipped("Backpack")
end

function PlayerWrap:SyncWithProfile()
    local ProfileData = self.Profile.Data

    local Table = {}
    for i,v in pairs(self.Items) do
        table.insert(Table, v:GetInfo())
    end
end

function PlayerWrap:AddItem(Item)
    table.insert(self.Items, Item)
    self.Replica:SetValue({"Items", #self.Profile.Data.Items + 1}, Item:GetInfo())
end

function PlayerWrap:RemoveItem(Item)
    local IsValid = table.find(self.Items, Item)
    if not IsValid then
        return "NotValid"
    end

    for i,v in pairs(self.Profile.Data.Equipped) do
        if self.Items[v] == Item then
            return "Equipped"
        end
    end

    local EquippedBefore = {}
    
    for i,v in pairs(self.Profile.Data.Equipped) do
        EquippedBefore[i] = self.Items[v]
    end

    table.remove(
        self.Items,
        table.find(self.Items, Item)
    )

    for i,v in pairs(self.Profile.Data.Equipped) do
        self.Replica:SetValue({"Equipped", i}, table.find(self.Items, v))
    end
end

function PlayerWrap:AutoDataPushAsync(Delay)
    self.StopPushing = false

    local Coroutine = coroutine.wrap(function()
        while not self.StopPushing do
            task.wait(Delay)
            self:SyncWithProfile()
        end
    end)

    Coroutine()
end

function PlayerWrap:StopPushing()
    self.StopPushing = true
end

return PlayerWrap