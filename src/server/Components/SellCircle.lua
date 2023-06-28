local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = ReplicatedStorage.Remotes
local QuestionClient = Remotes.QuestionClient

local Classes = ServerScriptService.Server.Classes
local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Components)

local PlayerWrap = require(Classes.PlayerWrap)

local SellCircle = Component.new({Tag = "SellCircle"})

local DefaultConfig = {
    Currency1 = {"Crops", "Wheat"},
    Currency2 = {"Coins"},
    ExchangeRate = 1,
    Cooldown = 3,
}

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

function SellCircle:Construct()
    self.PrimaryConnection = nil

    self.Config = {}
    self.Cooldowns = {}
    self.CurrentlyAwaiting = {}

    for i,v in pairs(DefaultConfig) do
        self.Config[i] = self.Instance:GetAttribute(i) or v
    end
end

function SellCircle:Start()
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

        task.delay(self.Config.Cooldown, function()
            table.remove(self.Cooldowns, table.find(self.Cooldowns, Player))
        end)

        local PlayerWrap = PlayerWrap.get(Player)

        local Table, Value = self:FindOnPath(
            PlayerWrap.Profile.Data, 
            self.Config.Currency1
        )

        local Table2, Value2 = self:FindOnPath(
            PlayerWrap.Profile.Data, 
            self.Config.Currency1
        )

        local Currency1 = Table[Value]

        if Currency1 <= 0 then
            return
        end

        table.insert(self.CurrentlyAwaiting, Player)

        local Question do
            local Currency1Name = self.Config.Currency1[#self.Config.Currency1]
            local Currency2Name = self.Config.Currency2[#self.Config.Currency2]
        
            local SellsFor = Currency1 * self.Config.ExchangeRate
            Question = "Do you want to sell "..Currency1.." "..Currency1Name.." for "..SellsFor.." "..Currency2Name
        end

        local Result
        pcall(function()
            Result = QuestionClient:InvokeClient(Player, Question)
        end)

        table.remove(self.CurrentlyAwaiting, table.find(self.CurrentlyAwaiting, Player))

        if not Result then
            return
        end

        local ExchangesFor = Currency1 * self.Config.ExchangeRate
        PlayerWrap.Calculations:Increment(
            self.Config.Currency2,
            ExchangesFor
        )

        PlayerWrap.Calculations:Set(
            self.Config.Currency1,
            0
        )
    end)
end

return SellCircle