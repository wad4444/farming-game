local Calculations = {}
Calculations.__index = Calculations

function Calculations.new(...)
    local self = setmetatable({}, Calculations)

    return self:Constructor(...) or self
end

function Calculations:Constructor(Player)
    self.Player = Player
end

function Calculations:ExistmentCheck(StatName)
    local Profile = self.Player.Profile
    local Stat = Profile.Data[StatName]

    if not Stat then
        error("There is no existing variable with provided name")
        return false
    end

    return true
end

function Calculations:FindStat(StatName)
    local Profile = self.Player.Profile
    local Stat = Profile.Data[StatName]

    return Stat
end

function Calculations:Increment(StatName, IncrementBy, CanGoNegative)
    self:ExistmentCheck(StatName)

    local Profile = self.Player.Profile
    local Stat = Profile.Data[StatName]

    if CanGoNegative then
        Profile.Data[StatName] += IncrementBy
        return true
    end

    if (Stat + IncrementBy) > 0 then
        Profile.Data[StatName] += IncrementBy
        return true
    end

    return false
end

function Calculations:Set(StatName, SetTo)
    self:ExistmentCheck(StatName)
    
    local Profile = self.Player.Profile
    Profile.Data[StatName] = SetTo
end

return Calculations