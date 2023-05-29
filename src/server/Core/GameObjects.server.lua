local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local ServerModules = ServerScriptService.Server
local Classes = {}

for i,v in pairs(ServerModules.Classes:GetChildren()) do
    if not v:IsA("ModuleScript") then
        continue
    end

    Classes[v.Name] = require(v)
end

local ObjectTags = {"Field"}

local Switch = {
    Field = function(FieldInstance)
        local Field = Classes.Field

        local Settings = Field.GetSettings()
        for i,v in pairs(Settings) do
            Settings[i] = FieldInstance:GetAttribute(i) or v
        end

        local NewField = Field.new(FieldInstance, Settings)
        NewField:Initialize()
    end
}

for i,v in pairs(ObjectTags) do
    local AllObjects = CollectionService:GetTagged(v)

    CollectionService:GetInstanceAddedSignal(v):Connect(function(...)
        Switch[v](...)
    end)

    for _,Object in pairs(AllObjects) do
        Switch[v](Object)
    end
end

for i,v in pairs(game.Workspace:GetChildren()) do
    if not v:IsA("Model") then
        continue
    end

    if v:FindFirstChildOfClass("Humanoid") then
        local Character = v
        local IsPlayer = Players:GetPlayerFromCharacter(Character)

        if IsPlayer then
            return
        end

        for i,v in pairs(v:GetDescendants()) do
            if not v:IsA("BasePart") then
                continue
            end

            if v.Anchored then
                return
            end

            v:SetNetworkOwner(nil)
        end
    end
end