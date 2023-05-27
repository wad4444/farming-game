local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local LoadedModules = {}
local Trashcan = game.Workspace.Trashcan

for i,v in ipairs(script:GetChildren()) do
    LoadedModules[v.Name] = require(v)
end

Remotes.CastEffect.OnClientEvent:Connect(function(EffectName, ...)
    if LoadedModules[EffectName] then
        LoadedModules[EffectName](...)
    end
end)

CollectionService:GetInstanceAddedSignal("Crop"):Connect(function(Crop)
    if Crop:IsDescendantOf(Trashcan) then
        return
    end

    LoadedModules.CropSpawn(Crop)
end)

return LoadedModules