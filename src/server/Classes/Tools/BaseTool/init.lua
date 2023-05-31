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
    Animations = {
        Hit = "SickleHit"
    },
    Cooldown = 1.5, 
    CustomName = nil,
    Upgrades = {},
    TrackerSettings = HitboxTracker.GetSettings()
}

function GetAnimationInstanceByName(AnimationName)
    local AnimationInstance = Assets.Animations:FindFirstChild(AnimationName)

    if not AnimationInstance then
        warn("Could not find animation by name '"..AnimationName.."'. Returning empty placeholder")
        return Instance.new("Animation")
    end

    return AnimationInstance
end

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

function Tool:StartDebounce()
    if self.Debounce then
        return
    end

    self.Debounce = true
    task.delay(self.Settings.Cooldown,function()
        self.Debounce = false
    end)
end

function Tool:InitializeTool()
    local Character = self.Player.Instance.Character or self.Player.Instance.CharacterAdded:Wait()

    local OriginalModel = ToolsPool:FindFirstChild(self.Settings.Type)
    local Backpack = self.Player.Instance:WaitForChild("Backpack")

    local NewTool = OriginalModel:Clone()
    NewTool.Parent = Backpack

    self.ToolInstance = NewTool
    self.Debounce = false
end

function Tool:InitializeAnimations()
    local PlayerInstance = self.Player.Instance
    local Character = PlayerInstance.Character or PlayerInstance.CharacterAdded:Wait()

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Animator = Humanoid:WaitForChild("Animator")

    self.LoadedAnimations = {}

    for i,v in pairs(self.Settings.Animations) do
        local HitAnimation = GetAnimationInstanceByName(self.Settings.Animations.Hit)
        local AnimationTrack = Animator:LoadAnimation(HitAnimation)

        self.LoadedAnimations[i] = AnimationTrack
    end
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

            self.LoadedAnimations.Hit:Play()

            local FoundCrops = self.HitboxTracker:TrackCrops()

            if #FoundCrops <= 0 then
                return
            end

            local FieldInstance = FoundCrops[1].Parent.Parent
            local FieldClass = FieldClass.Get(FieldInstance)

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
    self:InitializeAnimations()

    self.Player.Instance.CharacterAdded:Connect(self.InitializeAnimations)
end

return Tool