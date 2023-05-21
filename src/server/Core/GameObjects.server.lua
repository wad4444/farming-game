local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local ServerModules = ServerScriptService.Server
local Classes = {}

for i,v in pairs(ServerModules.Classes:GetChildren()) do
    Classes[v.Name] = require(v)
end

local ObjectTags = {"Field"}

local Switch = {
    Field = function(FieldInstance)
        local Field = Classes.Field

        local Settings = Field.getSettings()
        for i,v in pairs(Settings) do
            Settings[i] = FieldInstance:GetAttribute(i) or v
        end

        local NewField = Field.new(FieldInstance, Settings)
        NewField:Initialize()
    end
}

for i,v in pairs(ObjectTags) do
    local AllObjects = CollectionService:GetTagged(v)

    CollectionService:GetInstanceAddedSignal(v):Connect(function(...)
        Switch[v](...)
    end)

    for _,Object in pairs(AllObjects) do
        Switch[v](Object)
    end
end