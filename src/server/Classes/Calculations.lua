local Calculations = {}
Calculations.__index = Calculations

function Calculations.new(...)
    local self = setmetatable({}, Calculations)

    return self:Constructor(...) or self
end

function Calculations:Constructor(Player)
    self.Player = Player
    self.Replica = self.Player.Replica
end

function Calculations:FindOnPath(Path)
    local GlobalEntrancePoint = self.Player.Profile.Data
    local Splitted = Path

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

function Calculations:Increment(Path, IncrementBy, CanGoNegative)
    local Table, Stat = self:FindOnPath(Path)

    if Table and not Stat then
        error("Cant increment on a table")
    end

    if CanGoNegative then
        self.Replica:SetValue(Path, Table[Stat] + IncrementBy)

        return true
    end

    if (Table[Stat] + IncrementBy) < 0 then
        return
    end

    self.Replica:SetValue(Path, Table[Stat] + IncrementBy)

    return true
end

function Calculations:CanIncrement(Path, IncrementBy, CanGoNegative)
    local Table, Stat = self:FindOnPath(Path)

    if Table and not Stat then
        error("Cant increment on a table")
    end

    if CanGoNegative then
        return true
    end

    if (Table[Stat] + IncrementBy) < 0 then
        return
    end

    return true
end

function Calculations:Get(Path)
    local Table, Stat = self:FindOnPath(Path)

    return Table and Stat and Table[Stat] or Table
end

function Calculations:IncrementWithCapacity(Path, IncrementBy, Capacity, CanGoNegative)
    local Table, Stat = self:FindOnPath(Path)

    if Table and not Stat then
        error("Cant increment on a table")
    end

    if CanGoNegative then
        self.Replica:SetValue(Path, Table[Stat] + IncrementBy)

        return true
    end

    if (Table[Stat] + IncrementBy) < 0 then
        return
    end

    if (Table[Stat] + IncrementBy) > Capacity then
        return
    end

    
    self.Replica:SetValue(Path, Table[Stat] + IncrementBy)

    return true
end

function Calculations:CanIncrementWithCapacity(StatName, IncrementBy, Capacity, CanGoNegative)
    local Table, Stat = self:FindOnPath(StatName)

    if Table and not Stat then
        error("Cant increment on a table")
    end

    if CanGoNegative then
        return true
    end

    if (Table[Stat] + IncrementBy) < 0 then
        return
    end

    if (Table[Stat] + IncrementBy) > Capacity then
        return
    end

    return true
end

function Calculations:DifferenceFromCapacity(StatName, Capacity)
    local Table, Stat = self:FindOnPath(StatName)

    if Table and not Stat then
        error("Cant get difference on a table")
    end

    if typeof(Table[Stat]) ~= "number" then
        error("The end value must be a number")
    end

    return Capacity - Table[Stat]
end

function Calculations:Set(Path, SetTo)
    self.Replica:SetValue(Path, SetTo)
end

return Calculations