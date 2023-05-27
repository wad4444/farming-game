local Tools = script.Parent
local BaseTool = require(Tools.BaseTool)

local Super = BaseTool

local Sickle1 = setmetatable({},{
   __index = Super;
})
Sickle1.__index = Sickle1

function Sickle1.new(...)
    local self = setmetatable({}, Sickle1)

    return self:Constructor(...) or self
end

function Sickle1:Constructor(Player, Settings)
    local BaseSettings = BaseTool.GetSettings()

    for i,v in pairs(BaseSettings) do
        BaseSettings[i] = Settings[i] or v
    end

    if Super then
        Super.Constructor(self, Player, BaseSettings)
    end
end

return Sickle1