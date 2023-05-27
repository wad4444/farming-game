local Classes = script.Parent
local Calculations = require(Classes.Calculations)
local PurchaseHandler = require(Classes.PurchaseHandler)

local PlayerWrap = {}
PlayerWrap.__index = PlayerWrap

local InstanceToWrap = {}

function PlayerWrap.new(Instance, ...)
    local self = setmetatable({}, PlayerWrap)
    InstanceToWrap[Instance] = self
    return self:Constructor(Instance, ...) or self
end

function PlayerWrap.get(Instance)
    return InstanceToWrap[Instance]
end

function PlayerWrap:Constructor(Instance, Profile)
    self.Instance = Instance
    self.Profile = Profile

    local function ConvertToClass(FieldName)
        self[FieldName] = {}

        for i,v in pairs(Profile.Data[FieldName] or {}) do
            if not v.CLASS_NAME then
                continue
            end
    
            local ClassScript = Classes[FieldName]:FindFirstChild(v.CLASS_NAME)
            local Class = require(ClassScript)
            table.insert(self[FieldName], Class.new(Instance, v))
        end
    end

    ConvertToClass("Tools")
    ConvertToClass("Backpacks")

    self.Calculations = Calculations.new(self)
    self.PurchaseHandler = PurchaseHandler.new(self)
end

function PlayerWrap:Initialize()
    local Profile = self.Profile

    local function InitializeEquipped(Field, ListName)
        local Index = Profile.Data[Field]
        local IsIndexValid = #self[ListName] <= Index

        if not Index or not IsIndexValid then
            return 1
        end

        self[ListName][Index]:Initialize()
    end

    InitializeEquipped("EquippedTool", "Tools")
    InitializeEquipped("EquippedBackpack", "Backpacks")
end

function PlayerWrap:SyncWithProfile()
    local ProfileData = self.Profile.Data

    local function ConvertFromClass(FieldName)
        local Table = {}
        for i,v in pairs(self[FieldName]) do
            table.insert(Table, v:GetInfo())
        end
    end

    ProfileData.Tools = ConvertFromClass("Tools")
    ProfileData.Backpacks = ConvertFromClass("Backpacks")
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