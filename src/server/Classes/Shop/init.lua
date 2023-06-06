local ServerScriptService = game:GetService("ServerScriptService")
local ServerModules = ServerScriptService.Server
local Structures = ServerModules.Structures

local Configs = require(Structures.ShopConfigs)

local Shop = {}
Shop.__index = Shop

Shop.DefaultSettings = {
    Categories = {
        "Tools",
        "Backpacks"
    },
}

local InstanceToWrap = {}

function Shop.new(Instance, ...)
    local self = setmetatable({}, Shop)
    InstanceToWrap[Instance] = self

    return self:Constructor(Instance, ...) or self
end

function Shop.GetSettings()
    return table.clone(Shop.DefaultSettings)
end

function Shop.get(Instance)
   return InstanceToWrap[Instance]
end

function Shop:Constructor(Instance, ConfigName)
    self.Config = table.clone(Configs[ConfigName])
    self.Instance = Instance
end

return Shop