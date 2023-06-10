local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NonManagerPackages = ReplicatedStorage:WaitForChild("NonManagedPackages")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Roact = require(Packages.Roact)
local ClientDataHandler = require(Shared.Core.ClientDataHandler)
local UIParticles = require(NonManagerPackages.UIParticles)

local UIComponents = script.Parent

local StatBar = Roact.Component:extend("StatBar")

function StatBar:init()
    self.ValueName = self.props.Path[#self.props.Path]
    self.IconRef = Roact.createRef()
    
    self:setState({
        CounterValue = 0
    })
end

function StatBar:render()
    local BarElement = Roact.createElement("Frame", {
        Position = self.props.Position,
        Name = "Background",
        Size = self.props.Size or UDim2.fromScale(0.1325, 0.05),
        BackgroundColor3 = Color3.fromHex("ffffff")
    }, {
        Icon = Roact.createElement("ImageLabel", {
            Name = "Icon",
            Image = self.props.IconId,
            Position = UDim2.fromScale(0.75, -0.43),
            Size = UDim2.fromScale(0.35, 1.8),
            BackgroundTransparency = 1,

            [Roact.Ref] = self.IconRef
        }, {
            Roact.createElement("UIAspectRatioConstraint")
        }),
        UICorner = Roact.createElement("UICorner",{
            CornerRadius = UDim.new(1,0)
        }),
        UIStroke = Roact.createElement("UIStroke",{
            Color = Color3.fromHex("#ffdd34"),
            Thickness = 3,
        }),
        UIGradient = Roact.createElement("UIGradient",{
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHex("#ffffff")),
                ColorSequenceKeypoint.new(0.45, Color3.fromHex("#ffffff")),
                ColorSequenceKeypoint.new(1, Color3.fromHex("#d1d1d1"))
            })
        }),
        Counter = Roact.createElement("TextLabel",{
            Name = "Counter",
            Position = UDim2.fromScale(0.09, 0.11),
            Size = UDim2.fromScale(0.65, 0.75),
            Font = Enum.Font.FredokaOne,
            TextColor3 = Color3.fromHex("ffffff"),
            BackgroundTransparency = 1,
            TextScaled = true,

            Text = self.ValueName..": "..self.state.CounterValue
        },{
            TextGradient = Roact.createElement("UIGradient",{
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHex("#ffc20c")),
                    ColorSequenceKeypoint.new(0.35, Color3.fromHex("#ffc20c")),
                    ColorSequenceKeypoint.new(1, Color3.fromHex("#ff9602"))
                })
            })
        })
    })

    return BarElement
end

function StatBar:SetupParticles()
    if not self.Particles then
        self.Particles = {
            Stars = UIParticles.new(self.IconRef:getValue(), Assets.VFXPool.UIParticles.Star)
        }

        self.Particles.Stars.onSpawn = function(Particle)
            local randomizedSize = math.random(1,4)

            Particle.starterPosition = UDim2.fromScale(.5, .5)
            Particle.element.Size += UDim2.fromOffset(randomizedSize, randomizedSize)
            Particle.velocity = Vector2.new(math.random(-175, 175), math.random(-450,-250));
            Particle.maxAge = math.random(7,10)/10;
        end

        self.Particles.Stars.onUpdate = function(Particle, DeltaTime)
            Particle.velocity = Particle.velocity + Vector2.new(0, 10);
            Particle.element.ImageTransparency += 1 * DeltaTime
            Particle.element.Rotation += math.random(100,200) * DeltaTime
            Particle.position = Particle.position + (Particle.velocity/3 * DeltaTime);
        end
    end
end

function StatBar:ChangeEffect()
    self:SetupParticles()

    local Stars = self.Particles.Stars
    Stars:Emit(math.random(5,8))
end

function StatBar:didMount()
    self.IsActive = true

    ClientDataHandler.ChangeBind(self.props.Path, function(NewValue)
        if not self.IsActive then
            return
        end

        if self.state.CounterValue < NewValue then
            self:ChangeEffect()
        end

        self:setState({
            CounterValue = NewValue,
        })
    end)
end

function StatBar:willUnmount()
    self.IsActive = false

    for i,v in pairs(self.Particles) do
        v:Destroy()
    end
end

return StatBar