local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local ServerLibs = ServerScriptService.Server
local Packages = ServerScriptService.Packages
local ServerPackages = ServerScriptService.Packages

local DataStructure = require(ServerLibs.Structures.PlayerData)
local PlayerWrap = require(ServerLibs.Classes.PlayerWrap)

local Signal = require(ReplicatedStorage.Packages.Signal)

local DataHandler = {}
DataHandler.AutoDataPushDelay = 30
DataHandler.OnLoadData = Signal.new()

local ProfileService = require(ServerPackages.ProfileService)
local ProfileStore = ProfileService.GetProfileStore("im doing so much stressin :<", DataStructure.Structure)

local function PlayerAdded(player)
    local Profile = ProfileStore:LoadProfileAsync(tostring(player.UserId))

    if not Profile then
        player:Kick()
        return
    end

    Profile:AddUserId(player.UserId)
    Profile:Reconcile()
    
    Profile:ListenToRelease(function()
        player:Kick()
    end)

    if player:IsDescendantOf(Players) then
        DataHandler.OnLoadData:Fire(player, Profile)
        return
    end

    Profile:Release()
end

local function SaveData(player: Player)
    local Wrap = PlayerWrap.get(player)

    if not Wrap then
        return
    end

    local Profile = Wrap.Profile

    Wrap:SyncWithProfile()
    Profile:Release()
end

function DataHandler.Init()
    Players.PlayerAdded:Connect(PlayerAdded)
    Players.PlayerRemoving:Connect(SaveData)

    for i, player in pairs(Players:GetPlayers()) do
        task.spawn(PlayerAdded, player)
    end
end

return DataHandler