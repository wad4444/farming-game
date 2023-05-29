local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Server = ServerScriptService.Server

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local ToolsPool = Assets.Tools

local FieldClass = require(Server.Classes.Field)
local HitboxTracker = require(script.HitboxTracker)

local Tool = {}
Tool.__index = Tool

local DefaultSettings = {
    Type = "Sickle1",
    SetupType = "Default",
    CustomName = nil,
    Upgrades = {},
    TrackerSettings = HitboxTracker.GetSettings()
}

function Tool.GetSettings()
    return table.clone(DefaultSettings)
end

function Tool.new(...)
    local self = setmetatable({}, Tool)
    return self:Constructor(...) or self
end

function Tool:Constructor(Player, ToolSettings)
    self.Player = Player
    self.Settings = {}
    
    for i,v in pairs(DefaultSettings) do
        self.Settings[i] = ToolSettings[i] or v
    end

    self.HitboxTracker = HitboxTracker.new(self, self.Settings.TrackerSettings)
end

function Tool:Unload()
    if not self.ToolInstance then
        return
    end

    self.ToolInstance:Destroy()
end

function Tool:InitializeTool()
    local Character = self.Player.Instance.Character or self.Player.Instance.CharacterAdded:Wait()

    local OriginalModel = ToolsPool:FindFirstChild(self.Settings.Type)
    local Backpack = self.Player.Instance:WaitForChild("Backpack")

    local NewTool = OriginalModel:Clone()
    NewTool.Parent = Backpack

    self.ToolInstance = NewTool
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
            local FoundCrops = self.HitboxTracker:TrackCrops()

            if #FoundCrops <= 0 then
                return
            end

            local FieldInstance = FoundCrops[1].Parent.Parent
            local FieldClass = FieldClass.Get(FieldInstance)

            if not FieldClass then
                return
            end

            FieldClass:BreakCrops(self.Player, FoundCrops)
        end
    }

    Bridge.OnServerInvoke = function(Caller, Action)
        if Caller ~= self.Player.Instance then
            print("DOWN BAD")
            return
        end

        local FindAction = Actions[Action]
        if FindAction then
            return FindAction()
        end
    end

    Remotes.SetupTool:FireClient(self.Player.Instance, self.Settings.SetupType, self.ToolInstance)
end

function Tool:GetInfo()
    local Info = {}

    for i,v in pairs(DefaultSettings) do
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