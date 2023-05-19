local PurchaseHandler = {}
PurchaseHandler.__index = PurchaseHandler

function PurchaseHandler.new(...)
    local self = setmetatable({}, PurchaseHandler)

    return self:Constructor(...) or self
end

function PurchaseHandler:Constructor(Player)
    self.Player = Player
end

return PurchaseHandler