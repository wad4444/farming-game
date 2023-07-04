local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local UIComponents = script.Parent
local CustomButton2 = require(UIComponents.CustomButton2)
local InventoryFrame = require(UIComponents.InventoryFrame)

local Inventory = Roact.Component:extend("Inventory")

function Inventory:init()
    self.Toggled = false
    self.ToggleCallback = function()
        self.Toggled = not self.Toggled
     
        if self.Toggled then
            self.InventoryFrameExample:Open()
            return
        end

        self.InventoryFrameExample:Close()
    end
end

function Inventory:render()
    local InventoryInterface = Roact.createFragment({
        InventoryToggle = Roact.createElement(CustomButton2, {
            Position = self.props.ButtonPosition,
            Size = UDim2.fromScale(.1, .1),
            AspectRatio = 1,

            Callback = self.ToggleCallback
        }),
        InventoryFrame = Roact.createElement(InventoryFrame, {
            __GET = function(Example)
                self.InventoryFrameExample = Example
            end,
            ToggleCallback = self.ToggleCallback
        })
    })

    return InventoryInterface
end

return Inventory