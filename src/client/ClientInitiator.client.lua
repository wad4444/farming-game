local IsLoaded = game:IsLoaded() or game.Loaded:Wait()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local NonManagedPackages = ReplicatedStorage.NonManagedPackages

local DataHandler = require(Shared.Core.ClientDataHandler)
local WindMaker = require(NonManagedPackages.WindMaker)

require(Shared.Core.VisualEffectsHandler)

DataHandler.Initialize()

local Wind = WindMaker.new({
    Randomized = false,
    Velocity = Vector3.new(0.45, 0, 0),
    Amount = 3,
    Frequency = 0.5,
    Lifetime = 2,
    Amplitude = 0.35,
    Range = 100
})

Wind:Start()