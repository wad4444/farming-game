local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local ServerModules = ServerScriptService.Server
local Structures = ServerModules.Structures

for i,v in pairs(ServerModules.Components:GetChildren()) do
    if not v:IsA("ModuleScript") then
        continue
    end

    require(v)
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