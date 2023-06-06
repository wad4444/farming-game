local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = ReplicatedStorage.Remotes
local RequestSelling = Remotes.RequestSelling

local Classes = ServerScriptService.Server.Classes
local PlayerWrap = require(Classes.PlayerWrap)

local SellCircle = {}
SellCircle.__index = SellCircle

local InstanceToWrap = {}

SellCircle.DefaultSettings = {
    Currency1 = {"Crops", "Wheat"},
    Currency2 = {"Coins"},
    ExchangeRate = 1,
    Cooldown = 3,
}

function SellCircle.new(Instance, ...)
    local self = setmetatable({}, SellCircle)
    InstanceToWrap[Instance] = self

    return self:Constructor(Instance, ...) or self
end

function SellCircle.GetSettings()
    return table.clone(SellCircle.DefaultSettings)
end

function SellCircle:FindOnPath(GlobalEntrancePoint, Path)
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

function SellCircle.get(Instance)
   return InstanceToWrap[Instance]
end

function SellCircle:Constructor(Instance, Settings)
    self.Instance = Instance
    self.PrimaryConnection = nil

    self.Settings = {}
    self.Cooldowns = {}
    self.CurrentlyAwaiting = {}

    for i,v in pairs(SellCircle.DefaultSettings) do
        self.Settings[i] = Settings[i] or v
    end
end

function SellCircle:Initialize()
    self.PrimaryConnection = self.Instance.Touched:Connect(function(Hit)
        local PotentialCharacter = Hit:FindFirstAncestorOfClass("Model")
        local Humanoid = PotentialCharacter and PotentialCharacter:FindFirstChildOfClass("Humanoid")
        local Player = Humanoid and Players:GetPlayerFromCharacter(PotentialCharacter)

        if not Player then
            return
        end

        if table.find(self.Cooldowns, Player) or table.find(self.CurrentlyAwaiting, Player) then
            return
        end

        table.insert(self.Cooldowns, Player)

        task.delay(self.Settings.Cooldown, function()
            table.remove(self.Cooldowns, table.find(self.Cooldowns, Player))
        end)

        local PlayerWrap = PlayerWrap.get(Player)

        local Table, Value = self:FindOnPath(
            PlayerWrap.Profile.Data, 
            self.Settings.Currency1
        )

        local Table2, Value2 = self:FindOnPath(
            PlayerWrap.Profile.Data, 
            self.Settings.Currency1
        )

        local Currency1 = Table[Value]

        if Currency1 <= 0 then
            return
        end

        table.insert(self.CurrentlyAwaiting, Player)

        local Result = RequestSelling:InvokeClient(Player, self.Settings, Currency1)

        table.remove(self.CurrentlyAwaiting, table.find(self.CurrentlyAwaiting, Player))

        if not Result then
            return
        end

        local ExchangesFor = Currency1 * self.Settings.ExchangeRate
        PlayerWrap.Calculations:Increment(
            self.Settings.Currency2,
            ExchangesFor
        )

        PlayerWrap.Calculations:Set(
            self.Settings.Currency1,
            0
        )
    end)
end

return SellCircle