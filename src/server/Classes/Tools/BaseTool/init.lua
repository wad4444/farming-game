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
    local Character = self.Player.Character or self.Player.CharacterAdded:Wait()

    local OriginalModel = ToolsPool:FindFirstChild(self.Settings.Type)
    local Backpack = self.Player:WaitForChild("Backpack")

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
            
            if #FoundCrops > 0 then
                local FieldInstance = FoundCrops[1].Parent.Parent
                local FieldClass = FieldClass.Get(FieldInstance)

                if not FieldClass then
                    return
                end

                FieldClass:BreakCrops(FoundCrops)
            end
        end
    }

    Bridge.OnServerInvoke = function(Caller, Action)
        if Caller ~= self.Player then
            return
        end

        local FindAction = Actions[Action]
        if FindAction then
            return FindAction()
        end
    end

    Remotes.SetupTool:FireClient(self.Player, self.Settings.SetupType, self.ToolInstance)
end

function Tool:GetInfo()
    return {
        CLASS_NAME = self.Type,
        CustomName = self.CustomName,
        Upgrades = {}
    }
end

function Tool:Initialize()
    self:InitializeTool()
    self:InitializeBridge()
end

return Tool