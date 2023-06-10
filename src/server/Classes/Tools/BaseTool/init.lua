local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Server = ServerScriptService.Server

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local ToolsPool = Assets.Tools

local FieldComponent = require(Server.Components.Field)
local HitboxTracker = require(script.HitboxTracker)

local Tool = {}
Tool.__index = Tool

local DefaultConfig = {
    Type = "Sickle1",
    SetupType = "Default",
    Animations = {
        Hit = "SickleHit"
    },
    Cooldown = 1.5, 
    CustomName = nil,
    Upgrades = {},
    TrackerConfig = HitboxTracker.GetConfig()
}

function Tool.GetConfig()
    return table.clone(DefaultConfig)
end

function Tool.new(...)
    local self = setmetatable({}, Tool)
    return self:Constructor(...) or self
end

function Tool:Constructor(Player, ToolConfig)
    self.Player = Player
    self.Config = {}
    
    for i,v in pairs(DefaultConfig) do
        self.Config[i] = ToolConfig[i] or v
    end

    self.HitboxTracker = HitboxTracker.new(self, self.Config.TrackerConfig)
end

function Tool:Unload()
    if not self.ToolInstance then
        return
    end

    self.ToolInstance:Destroy()
end

function Tool:StartDebounce()
    if self.Debounce then
        return
    end

    self.Debounce = true
    task.delay(self.Config.Cooldown,function()
        self.Debounce = false
    end)
end

function Tool:InitializeTool()
    local Character = self.Player.Instance.Character or self.Player.Instance.CharacterAdded:Wait()

    local OriginalModel = ToolsPool:FindFirstChild(self.Config.Type)
    local Backpack = self.Player.Instance:WaitForChild("Backpack")

    local NewTool = OriginalModel:Clone()
    NewTool.Parent = Backpack

    self.ToolInstance = NewTool
    self.Debounce = false
end

function Tool:InitializeBridge()
    if not self.ToolInstance then
        warn("You tried to initialize bridge of tool instance before initializing tool")
        return
    end

    local Bridge = Instance.new("RemoteFunction", self.ToolInstance)
    Bridge.Name = "Bridge"

    local Actions = {
        Activated = function()
            if self.Debounce then
                return
            end
            
            self:StartDebounce()
            self.Player:PlayAnimation(self.Config.Animations.Hit)

            local FoundCrops = self.HitboxTracker:TrackCrops()

            if #FoundCrops <= 0 then
                return
            end

            local FieldInstance = FoundCrops[1].Parent.Parent
            local FieldClass = FieldComponent:FromInstance(FieldInstance)

            if not FieldClass then
                return
            end

            return FieldClass:BreakCrops(self.Player, FoundCrops)
        end
    }

    Bridge.OnServerInvoke = function(Caller, Action)
        if Caller ~= self.Player.Instance then
            return
        end

        local FindAction = Actions[Action]
        if FindAction then
            return FindAction()
        end
    end

    Remotes.SetupTool:FireClient(self.Player.Instance, self.Config.SetupType, self.ToolInstance)
end

function Tool:GetInfo()
    local Info = {}

    for i,v in pairs(DefaultConfig) do
        local IsDefault = self[i] == v
        Info[i] = not IsDefault and self[i] or nil
    end

    return Info
end

function Tool:Initialize()
    self:InitializeTool()
    self:InitializeBridge()
end

return Tool