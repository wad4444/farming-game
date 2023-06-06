local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModules = ServerScriptService.Server
local Structures = ServerModules.Structures

local Shared = ReplicatedStorage.Shared
local Component = require(Shared.Libraries.Components)

local Configs = require(Structures.ShopConfigs)

local Shop = Component.new({Tag = "Shop"})

local DefaultSettings = {
    Categories = {
        "Tools",
        "Backpacks"
    },
}

local InstanceToWrap = {}

function Shop:Construct()
    local ConfigName = self.Instance:GetAttribute("Config")

    self.Config = table.clone(Configs[ConfigName])
end

return Shop