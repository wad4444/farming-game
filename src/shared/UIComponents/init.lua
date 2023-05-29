local LoadedModules = {}

for i,v in ipairs(script:GetChildren()) do
    LoadedModules[v.Name] = require(v)
end

return LoadedModules