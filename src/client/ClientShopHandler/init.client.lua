local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShopBridge = Remotes.Shop

local OpenAnims = {}
for i,v in ipairs(script:GetChildren()) do
    if not v:IsA("ModuleScript") then
        continue
    end

    OpenAnims[v.Name] = require(v)
end

local CurrentlySelectedShop

local ActionSwitch = {
    Open = function(Shop)
        local Case = OpenAnims[Shop.Id]

        if not Case then
            return
        end
    
        Case(Shop)
    end
}

ShopBridge.OnClientInvoke = function(Action, ...)
    local Case = ActionSwitch[Action]

    if not Case then
        return
    end

    Case(...)
end