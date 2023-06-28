local ShopItem = {}
ShopItem.__index = ShopItem

local InstanceToWrap = {}

ShopItem.DefaultConfig = {
    Price = 100,
    Name = "Sickle1",
    DisplayName = "Sickle1",
    Currency = "Coins",
    Category = "Tools"
}

function ShopItem.new(Instance, ...)
    local self = setmetatable({}, ShopItem)
    InstanceToWrap[Instance] = self

    return self:Constructor(Instance, ...) or self
end

function ShopItem.get(Instance)
   return InstanceToWrap[Instance]
end

function ShopItem.GetConfig()
    return table.clone(ShopItem.DefaultConfig)
end

function ShopItem:Constructor(Instance, Config)
    self.Instance = Instance

    self.Config = {}

    for i,v in pairs(ShopItem.DefaultConfig) do
        self.Config[i] = Config[i] or v
    end
end

return ShopItem