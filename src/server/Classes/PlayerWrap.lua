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

        for i,v in pairs(Profile[FieldName]) do
            if not v.CLASS_NAME then
                continue
            end
    
            local ToolClass = Classes.Tools:FindFirstChild(v.CLASS_NAME)
            table.insert(self[FieldName], ToolClass.new(Instance, v))
        end
    end

    ConvertToClass("Tools")
    ConvertToClass("Backpacks")

    self.Calculations = Calculations.new(self)
    self.PurchaseHandler = PurchaseHandler.new(self)
end

function PlayerWrap:SyncWithProfile()
    local Profile = self.Profile

    local function ConvertFromClass(FieldName)
        local Table = {}
        for i,v in pairs(self[FieldName]) do
            table.insert(Table, v:GetInfo())
        end
    end

    Profile.Tools = ConvertFromClass("Tools")
    Profile.Backpacks = ConvertFromClass("Backpacks")
end

function PlayerWrap:AutoDataPushAsync(Delay)
    self.StopPushing = false

    local Coroutine = coroutine.create(function()
        while not self.StopPushing do
            task.wait(Delay)
            self:SyncWithProfile()
        end
    end)

    coroutine.wrap(Coroutine)
end

function PlayerWrap:StopPushing()
    self.StopPushing = true
end

return PlayerWrap