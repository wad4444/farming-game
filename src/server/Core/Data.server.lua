local ServerScriptService = game:GetService("ServerScriptService")
local ServerScripts = ServerScriptService.Server

local Classes = ServerScripts.Classes
local Handlers = ServerScripts.Handlers

local DataHandler = require(Handlers.DataHandler)
local PlayerWrap = require(Classes.PlayerWrap)

DataHandler.OnLoadData:Connect(function(Player, Profile)
    local NewWrap = PlayerWrap.new(Player, Profile)
    NewWrap:AutoDataPushAsync(DataHandler.AutoDataPushDelay)
end)

DataHandler.Init()