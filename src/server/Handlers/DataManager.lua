local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Shared.Libraries.Signal)
local DataStructure = require(ServerScriptService.Server.Structures.PlayerData)

local DataHandler = {}
DataHandler.Profiles = {}

DataHandler.OnLoadData = Signal.new()
DataHandler.OnSaveData = Signal.new()

local ProfileService = require(ServerScriptService.Server.Libraries.ProfileService)
local ProfileStore = ProfileService.GetProfileStore("PlayerDataStore", DataStructure)

local function PlayerAdded(player)
    local Profile = ProfileStore:LoadProfileAsync(tostring(player.UserId))

    if not Profile then
        player:Kick()
        return
    end

    Profile:AddUserId(player.UserId)
    Profile:Reconcile()
    
    Profile:ListenToRelease(function()
        DataHandler.Profiles[player] = nil
        player:Kick()
    end)

    if player:IsDescendantOf(Players) then
        DataHandler.Profiles[player] = Profile
        DataHandler.OnLoadData:Fire(player, Profile)
        return;
    end

    Profile:Release()
end

local function SaveData(player: Player)
    local Profile = DataHandler.Profiles[player]

    if not Profile then
        return
    end

    DataHandler.OnSaveData:Fire(player, Profile)
    task.wait()
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