local Calculations = {}
Calculations.__index = Calculations

function Calculations.new(...)
    local self = setmetatable({}, Calculations)

    return self:Constructor(...) or self
end

function Calculations:Constructor(Player)
    self.Player = Player
end

function Calculations:FindOnPath(Path)
    local GlobalEntrancePoint = self.Player.Profile.Data
    local Splitted = typeof(Path) == "string" and string.split(Path, ".") or Path

    if #Splitted < 1 then
        error("Provided table path is not valid")
    end

    local function PathRecursive(Entrance, CurrentIndex)
        local Index = Splitted[CurrentIndex]
        local CurrentPoint = Entrance[Index]

        if not CurrentPoint then
            error("Provided table path is not valid")
        end

        if typeof(CurrentPoint) == "table" then
            if Splitted[CurrentIndex + 1] then
                return PathRecursive(CurrentPoint, CurrentIndex + 1)
            else
                return CurrentPoint
            end
        else
            return Entrance, Index
        end
    end

    return PathRecursive(GlobalEntrancePoint, 1)
end

function Calculations:FindStat(StatName)
    local Profile = self.Player.Profile
    local Stat = Profile.Data[StatName]

    return Stat
end

function Calculations:Increment(StatName, IncrementBy, CanGoNegative)
    local Table, Stat = self:FindOnPath(StatName)

    if Table and not Stat then
        error("Cant increment on a table")
    end

    if CanGoNegative then
        Table[Stat] += IncrementBy
        return true
    end

    if (Table[Stat] + IncrementBy) < 0 then
        return
    end

    Table[Stat] += IncrementBy

    return true
end

function Calculations:IncrementWithCapacity(StatName, IncrementBy, Capacity, CanGoNegative)
    local Table, Stat = self:FindOnPath(StatName)

    if Table and not Stat then
        error("Cant increment on a table")
    end

    if CanGoNegative then
        Table[Stat] += IncrementBy
        return true
    end

    if (Table[Stat] + IncrementBy) < 0 then
        return
    end

    if (Table[Stat] + IncrementBy) > Capacity then
        return
    end

    Table[Stat] += IncrementBy

    return true
end

function Calculations:Set(StatName, SetTo)
    local Table, Stat = self:FindOnPath(StatName)

    if Table and not Stat then
        Table = SetTo
    else
        Table[Stat] = SetTo
    end
end

return Calculations