local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModules = ServerScriptService.Server
local Structures = ServerModules.Structures
local Classes = ServerModules.Classes

local Packages = ReplicatedStorage.Packages
local Remotes = ReplicatedStorage.Remotes

local Component = require(Packages.Components)
local ShopBridge = Remotes.Shop
local QuestionClient = Remotes.QuestionClient
local PlayerWrap = require(Classes.PlayerWrap)

local Configs = require(Structures.ShopConfigs)

local Shop = Component.new({Tag = "Shop"})

local DefaultConfig = {
    Categories = {
        Tools = {},
        Backpacks = {}
    },
    Cooldown = 3,
    Id = "Shop1",
}

local ShopIdToClassExample = {}

function Shop:Construct()
    local ConfigName = self.Instance:GetAttribute("Config")
    local Config = table.clone(Configs[ConfigName] or DefaultConfig)

    ShopIdToClassExample[Config.Id] = self

    self.Config = {}
    self.Cooldown = {}
    self.CurrentlyAwaiting = {}
    self.InShop = {}

    self.RestrictedLists = {self.Cooldown, self.CurrentlyAwaiting, self.InShop}

    for i,v in pairs(DefaultConfig) do
        self.Config[i] = Config[i] or v
    end

    if not self.Instance:FindFirstChild("Items") then
        error("Shop can't be loaded, no 'ItemModels' folder found")
    end

    self.Models = self.Instance:WaitForChild("Items")
    self.Entrance = self.Instance.Entrance
end

function Shop:FindItem(Name, Category)
    for i,v in pairs(self.Config.Categories[Category]) do
        if v.ID ~= Name then
            continue
        end

        return v
    end
end

function Shop:Start()
    self.EntranceConnection = self.Entrance.Touched:Connect(function(Hit)
        local PotentialCharacter = Hit:FindFirstAncestorOfClass("Model")
        local Humanoid = PotentialCharacter and PotentialCharacter:FindFirstChildOfClass("Humanoid")
        local Player = Humanoid and Players:GetPlayerFromCharacter(PotentialCharacter)

        for _, List in pairs(self.RestrictedLists) do
            if table.find(List, Player) then
                return
            end
        end

        table.insert(self.Cooldown, Player)
        task.delay(self.Config.Cooldown, function()
            table.remove(
                self.Cooldown,
                table.find(self.Cooldown, Player)
            )
        end)

        table.insert(self.CurrentlyAwaiting, Player)

        local Question = "Do you want to enter the shop?"
        local Result
        pcall(function()
            Result = QuestionClient:InvokeClient(Player, Question)
        end)

        table.remove(
            self.CurrentlyAwaiting,
            table.find(self.CurrentlyAwaiting, Player)
        )

        if not Result then
            return
        end

        local ClientConfig = table.clone(self.Config)
        ClientConfig['Instance'] = self.Instance

        table.insert(self.InShop, Player)
        Humanoid.Died:Connect(function()
            local PlayerIndex = table.find(self.InShop, Player)
            
            if PlayerIndex then
                table.remove(self.InShop, PlayerIndex)
            end
        end)

        ShopBridge:InvokeClient(Player, "Open", ClientConfig)
    end)
end

function Shop:ProcessAction(PlayerInstance, ActionName, ...)
    local Actions = {
        Buy = function(RequestInfo)
            if typeof(RequestInfo) ~= "table" then
                return
            end

            if not RequestInfo.Category or not RequestInfo.Item then
                return
            end

            if typeof(RequestInfo.Category) ~= "string" or typeof(RequestInfo.Item) ~= "string" then
                return
            end

            local ShopItem = self:FindItem(RequestInfo.Item, RequestInfo.Category)
            local Player = PlayerWrap.get(PlayerInstance)

            if not Player or not ShopItem then
                return
            end

            if Player:HasItem(RequestInfo.Item) then
                return
            end

            local Calculations = Player.Calculations

            if not Calculations:CanIncrement({ShopItem.Currency}, -ShopItem.Price) then
                return false
            end

            Calculations:Increment({ShopItem.Currency}, -ShopItem.Price)
            Player:AddItem(RequestInfo.Item)
            Player:EquipItem(RequestInfo.Item)
        end,
        Equip = function(RequestInfo)
            if typeof(RequestInfo) ~= "table" then
                return
            end

            if not RequestInfo.Item or not RequestInfo.Category then
                return
            end

            if typeof(RequestInfo.Item) ~= "string" or typeof(RequestInfo.Category) ~= "string" then
                return
            end

            local ShopItem = self:FindItem(RequestInfo.Item, RequestInfo.Category)
            local Player = PlayerWrap.get(PlayerInstance)

            if not ShopItem or not Player then
                return
            end

            if not Player:HasItem(RequestInfo.Item) then
                return
            end

            for i,v in pairs(Player.Equipped) do
                if v.ID == RequestInfo.Item then
                    return
                end
            end

            Player:EquipItem(RequestInfo.Item)
        end,
        Close = function()
            local Index = table.find(self.InShop, PlayerInstance)

            if Index then
                table.remove(self.InShop, Index)
            end
        end
    }

    local Case = Actions[ActionName]
    if Case then
        Case(...)
    end
end

ShopBridge.OnServerInvoke = function(Player, ShopName, ...)
    local ShopInstance = ShopIdToClassExample[ShopName]

    if not ShopInstance then
        return
    end

    ShopInstance:ProcessAction(Player, ...)
end

return Shop