local IsLoaded = game:IsLoaded() or game.Loaded:Wait()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local DataHandler = require(Shared.Core.ClientDataHandler)

require(Shared.Core.VisualEffectsHandler)

DataHandler.Initialize()
