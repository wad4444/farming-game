local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModules = ServerScriptService.Server
local Structures = ServerModules.Structures

local Packages = ReplicatedStorage.Packages
local Remotes = ReplicatedStorage.Remotes

local Component = require(Packages.Components)
local ShopBridge = Remotes.Shop
local QuestionClient = Remotes.QuestionClient

local Configs = require(Structures.ShopConfigs)

local Shop = Component.new({Tag = "Shop"})
local ShopItem = require(script.ShopItem)

local DefaultConfig = {
    Categories = {
        "Tools",
        "Backpacks"
    },
    Cooldown = 3,
    Id = "Shop1",
}

function Shop:Construct()
    local ConfigName = self.Instance:GetAttribute("Config")
    local Config = table.clone(Configs[ConfigName] or DefaultConfig)

    self.Config = {}
    self.Items = {}
    self.Cooldown = {}
    self.CurrentlyAwaiting = {}

    for i,v in pairs(DefaultConfig) do
        self.Config[i] = Config[i] or v
    end

    if not self.Instance:FindFirstChild("Items") then
        error("Shop can't be loaded, no 'ItemModels' folder found")
    end

    self:WaitForInstance(self.Instance.Items):andThen(function()
        self.Models = self.Instance.Items

        for Category,Items in pairs(self.Config.Categories) do
            for _,ItemConfig in pairs(Items) do
                local ItemModel = self.Models:FindFirstChild(ItemConfig.Name)
                
                if not ItemModel then
                    warn("Could not find model for item '"..ItemConfig.Name.."'")
                    continue
                end
    
                local NewShopItem = ShopItem.new(ItemModel, ItemConfig)
                table.insert(self.Items, NewShopItem)
            end
        end
    end)

    self.Entrance = self.Instance.Entrance
end

function Shop:Start()
    self.EntranceConnection = self.Entrance.Touched:Connect(function(Hit)
        local PotentialCharacter = Hit:FindFirstAncestorOfClass("Model")
        local Humanoid = PotentialCharacter and PotentialCharacter:FindFirstChildOfClass("Humanoid")
        local Player = Humanoid and Players:GetPlayerFromCharacter(PotentialCharacter)

        if not Player or table.find(self.Cooldown, Player) or table.find(self.CurrentlyAwaiting, Player) then
            return
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
        local Result = QuestionClient:InvokeClient(Player, Question)

        table.remove(
            self.CurrentlyAwaiting,
            table.find(self.CurrentlyAwaiting, Player)
        )

        if not Result then
            return
        end

        local ClientConfig = table.clone(self.Config)
        ClientConfig['Instance'] = self.Instance

        ShopBridge:InvokeClient(Player, "Open", ClientConfig)
    end)
end

return Shop