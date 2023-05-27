local Tools = script.Parent
local BasePack = require(Tools.BaseBackpack)

local Super = BasePack

local Backpack1 = setmetatable({},{
   __index = Super;
})
Backpack1.__index = Backpack1

function Backpack1.new(...)
    local self = setmetatable({}, Backpack1)

    return self:Constructor(...) or self
end

function Backpack1:Constructor(Player, Settings)
    local BaseSettings = BasePack.GetSettings()

    for i,v in pairs(BaseSettings) do
        BaseSettings[i] = Settings[i] or v
    end

    if Super then
        Super.Constructor(self, Player, BaseSettings)
    end
end

return Backpack1