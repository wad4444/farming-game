local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientHandler = {}
local Binds = {}
local AddCallback = nil

local Initialized = false

local NonManagedPackages = ReplicatedStorage.NonManagedPackages
local ReplicaController = require(NonManagedPackages.ReplicaController)

local function AllocatePath(GlobalEntrancePoint, Path)
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

function ClientHandler.ChangeBind(Path, Callback)
    if not Initialized then
        Binds[Path] = Callback
        return
    end

    AddCallback(Path, Callback)
end

function ClientHandler.Initialize()
    if Initialized then
        warn("You can't initialize client data handler twice")
        return
    end

    ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
        Initialized = true

        AddCallback = function(Path, Callback)
            local Table, Index = AllocatePath(Replica.Data, Path)
            Callback(Table and Index and (Table[Index]) or Table and Table or nil)

            Replica:ListenToChange(Path, Callback)
        end

        for Path,Callback in pairs(Binds) do
            local Table, Index = AllocatePath(Replica.Data, Path)
            Callback(Table and Index and (Table[Index]) or Table and Table or nil)

            Replica:ListenToChange(Path, Callback)
        end

        _G.ProfileData = Replica.Data
        Replica:ConnectOnClientEvent(function()
            _G.ProfileData = Replica.Data
        end)
    end)

    ReplicaController.RequestData()
end

return ClientHandler