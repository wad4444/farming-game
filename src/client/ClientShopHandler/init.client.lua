local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local UIComponents = require(Shared.UIComponents)
local ShopBridge = Remotes.Shop
local Roact = require(Packages.Roact)

local ToolAnimationParams = {
    Speed = 2.5,
    RotationSpeed = 1.5,
    HeightDifference = .0225
}

local OpenAnims = {}
for i,v in ipairs(script:GetChildren()) do
    if not v:IsA("ModuleScript") then
        continue
    end

    OpenAnims[v.Name] = require(v)
end

local CurrentlySelectedShop
local CurrentIndex = 1
local CurrentAction

local Camera = game.Workspace.CurrentCamera
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local function MoveCamera(Destination, Time)
    Destination = typeof(Destination) == "Instance" and Destination.CFrame or Destination

    local Tween = TweenService:Create(Camera,TweenInfo.new(
        Time or .2,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut
    ), {CFrame = Destination})
    Tween:Play()
end

local ActionSwitch = {
    Open = function(Shop)
        local PlayOpenAnimation = OpenAnims[Shop.Id]

        if not PlayOpenAnimation then
            return
        end

        CurrentlySelectedShop = Shop

        local CategoryName, Category = next(Shop.Categories)
        local FirstItem = Category[CurrentIndex]

        local function InitializeAnimation()
            for i,v in pairs(Category) do
                local Model = Shop.Instance.Items:FindFirstChild(v.ID).ItemModel

                task.spawn(function()
                    local CosAngle = 0
        
                    while Shop == CurrentlySelectedShop do
                        RunService.RenderStepped:Wait()

                        local CurrentCFrame = Model:GetPivot()
                        local NewCFrame = CurrentCFrame + Vector3.new(0,ToolAnimationParams.HeightDifference * math.cos(math.rad(CosAngle)),0)

                        Model:PivotTo(NewCFrame * CFrame.Angles(0,math.rad(ToolAnimationParams.RotationSpeed),0))

                        CosAngle += ToolAnimationParams.Speed
                    end
                end)
            end

            local Model = Shop.Instance.Items:FindFirstChild(FirstItem.ID) do
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = Model.CameraPoint.CFrame
            end
        end

        local function UpdateAction()
            local Item = Category[CurrentIndex]

            for i,v in pairs(_G.ProfileData.Equipped) do
                if v == Item.ID then
                    CurrentAction = "Equipped"
                    return
                end
            end

            if table.find(_G.ProfileData.Items, Item.ID) then
                CurrentAction = "Equip"
                return
            end

            CurrentAction = "Buy"
            return
        end

        local function InitializeShop()
            CurrentIndex = 1
 
            InitializeAnimation()
            UpdateAction()

            local InterfaceTree
            local InterfaceExample

            local InterfaceElement = Roact.createElement(UIComponents.ShopInterface, {
                Callbacks = {
                    LeftArrow = function()
                        CurrentIndex = CurrentIndex - 1 < 1 and #Category or CurrentIndex - 1

                        local Item = Category[CurrentIndex]
                        local ItemInstance = Shop.Instance.Items:FindFirstChild(Item.ID)

                        UpdateAction()

                        InterfaceExample:setState({
                            Item = Item,
                            Action = CurrentAction
                        })

                        MoveCamera(ItemInstance.CameraPoint)
                    end,
                    RightArrow = function()
                        CurrentIndex = CurrentIndex + 1 > #Category and 1 or CurrentIndex + 1

                        local Item = Category[CurrentIndex]
                        local ItemInstance = Shop.Instance.Items:FindFirstChild(Item.ID)

                        UpdateAction()

                        InterfaceExample:setState({
                            Item = Item,
                            Action = CurrentAction
                        })

                        MoveCamera(ItemInstance.CameraPoint)
                    end,
                    BuyButton = function()
                        if CurrentAction == "Equipped" then
                            return
                        end

                        ShopBridge:InvokeServer(
                            CurrentlySelectedShop.Id,
                            CurrentAction, 
                            {
                                Category = CategoryName,
                                Item = Category[CurrentIndex].ID
                            }
                        )

                        UpdateAction()
                        InterfaceExample:setState({
                            Item = InterfaceExample.state.Item,
                            Action = CurrentAction
                        })
                    end,
                    Close = function()
                        OpenAnims.CloseShop(function()
                            Roact.unmount(InterfaceTree)
                        end)

                        ShopBridge:InvokeServer(
                            CurrentlySelectedShop.Id,
                            "Close"
                        )
                    end
                },
                StartingState = {
                    Item = FirstItem,
                    Action = CurrentAction
                },
                ReturnExample = function(PureExample)
                    InterfaceExample = PureExample
                end
            })

            InterfaceTree = Roact.mount(InterfaceElement, PlayerGui)
        end
    
        PlayOpenAnimation(Shop, InitializeShop)
    end
}

ShopBridge.OnClientInvoke = function(Action, ...)
    local Case = ActionSwitch[Action]

    if not Case then
        return
    end

    Case(...)
end