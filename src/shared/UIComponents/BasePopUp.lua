local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Roact = require(Shared.Libraries.Roact)

local UIComponents = script.Parent
local CustomButton1 = require(UIComponents.CustomButton1)

local PopUp = Roact.Component:extend("PopUp")

function PopUp:init()
    self.TweenCases = {
        TextLabel = {
            ["TextTransparency"] = 1,
            ["BackgroundTransparency"] = 1
        },
        TextButton = {
            ["TextTransparency"] = 1,
            ["BackgroundTransparency"] = 1
        },
        Frame = {
            ["BackgroundTransparency"] = 1
        },
        ImageLabel = {
            ["ImageTransparency"] = 1
        },
        ImageButton = {
            ["ImageTransparency"] = 1
        },
    }
    self.EnableCases = {
        UIStroke = {
            ["Enabled"] = false
        }
    }

    self.CanTween = function()
        if self._Destroying then
            return
        end

        return true
    end

    self.MainFrameRef = Roact.createRef()
end

function PopUp:render()
    local ChildrenTable = {
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(.05, 0)
        }),
        UIStroke = Roact.createElement("UIStroke", {
            Thickness = 8,
            Color = Color3.fromHex("ffdd34"),
        }),
        Title = Roact.createElement("TextLabel",{
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(-0.2, -0.1),
            Rotation = -10,
            Size = UDim2.fromScale(0.4, 0.2),
            TextScaled = true,
            Font = Enum.Font.FredokaOne,
            Text = "Hey!",
            TextColor3 = Color3.fromHex("ffffff")
        },{
            Roact.createElement("UIStroke", {
                Thickness = 5,
                Color = Color3.fromHex("ffdd34")
            })
        }),
        Texture = Roact.createElement("ImageLabel", {
            Name = "Texture",
            Image = "rbxassetid://13606808259",
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            ImageTransparency = .9,
        }),
        CloseButton = Roact.createElement(CustomButton1, {
            Position = UDim2.fromScale(1.005, -.025),
            AspectRatio = 1,
            Size = UDim2.fromScale(.09, .2),
            Text = "X",

            CanTween = self.CanTween,

            Callback = function()
                if self.props.Callback then
                    self.props.Callback(false)
                end

                self:Close()
            end
        }),
        MessageLabel = Roact.createElement("TextLabel", {
            BackgroundTransparency = 1,
            TextScaled = true,
            TextColor3 = Color3.fromHex("ffffff"),
            Position = UDim2.fromScale(.075, .1),
            Size = self.props.MessageLabelSize or UDim2.fromScale(.83, .75),
            Font = Enum.Font.FredokaOne,

            Text = self.props.Text,
        }, {
            UIStroke = Roact.createElement("UIStroke", {
                Thickness = 4,
                Color = Color3.fromHex("ffdd34"),
            }),
        }),
    }

    for i,v in pairs(self.props.Buttons) do
        ChildrenTable[i] = v
        v.props.CanTween = self.CanTween

        v.props.Callback = function()
            self:Close()

            if not v.props.CallbackFunction then
                return  
            end

            v.props.CallbackFunction(table.unpack(v.props.CallbackArguments))
        end
    end

    local PopUpFrame = Roact.createElement("Frame", {
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromScale(.4, .5),
        Name = "PopUp",
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = Color3.fromHex("ffffff"),

        [Roact.Ref] = self.MainFrameRef
    }, ChildrenTable)

    return PopUpFrame
end

function PopUp:Close()
    local DisappearTime = .25
    local MainFrame = self.MainFrameRef:getValue()

    local Properties = {
        [MainFrame] = {
            Size = UDim2.fromScale(
                MainFrame.Size.X.Scale/1.5,
                MainFrame.Size.Y.Scale/1.5
            ),
            BackgroundTransparency = 1
        }
    }

    for i,v in pairs(MainFrame:GetDescendants()) do
        if self.EnableCases[v.ClassName] then
            for PropertyName, SetTo in pairs(self.EnableCases[v.ClassName]) do
                v[PropertyName] = SetTo
            end
        end

        if not self.TweenCases[v.ClassName] then
            continue
        end

        Properties[v] = {}

        for PropertyName, SetTo in pairs(self.TweenCases[v.ClassName]) do
            Properties[v][PropertyName] = SetTo
        end
    end

    for i,v in pairs(Properties) do
        TweenService:Create(i, TweenInfo.new(DisappearTime, Enum.EasingStyle.Sine), v):Play()
    end

    self._Destroying = true

    task.wait(DisappearTime)

    if self.props.UnmountCallback then
        self.props.UnmountCallback()
    end
end

function PopUp:didMount()
    local AppearTime = .25

    local MainFrame = self.MainFrameRef:getValue()
    local OriginalSize = MainFrame.Size

    local OriginalProperties = {}
    for i,v in pairs(MainFrame:GetDescendants()) do
        if not v:IsA("GuiObject") then
            continue
        end

        OriginalProperties[v] = {}

        for PropertyName,SetTo in pairs(self.TweenCases[v.ClassName]) do
            OriginalProperties[v][PropertyName] = v[PropertyName]
            v[PropertyName] = SetTo
        end
    end

    OriginalProperties[MainFrame] = {
        BackgroundTransparency = MainFrame.BackgroundTransparency,
        Size = MainFrame.Size
    }

    MainFrame.Size = UDim2.fromScale(
        MainFrame.Size.X.Scale/1.5,
        MainFrame.Size.Y.Scale/1.5
    )
    MainFrame.BackgroundTransparency = 1

    for i,v in pairs(OriginalProperties) do
        TweenService:Create(i, TweenInfo.new(AppearTime, Enum.EasingStyle.Sine), v):Play()
    end
end

return PopUp