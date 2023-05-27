local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local LoadedModules = {}

for i,v in ipairs(script:GetChildren()) do
    LoadedModules[v.Name] = require(v)
end

Remotes.CastEffect.OnClientEvent:Connect(function(EffectName, ...)
    if LoadedModules[EffectName] then
        LoadedModules[EffectName](...)
    end
end)

return LoadedModules