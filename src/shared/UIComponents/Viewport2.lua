local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Roact = require(Packages.Roact)

local Viewport2 = Roact.Component:extend("Viewport2")

function Viewport2:init()
    self.CameraRef = Roact.createRef()
    self.ViewportRef = Roact.createRef()

    if self.props.__GET then
        self.props.__GET(self)
    end
end

function Viewport2:render()
    local ViewportCamera = Roact.createElement("Camera", {
        [Roact.Ref] = self.CameraRef,
        CFrame = self.CameraCFrame
    })

    local Viewport = Roact.createElement("ViewportFrame", {
        Position = self.props.Position,
        Size = self.props.Size,
        ZIndex = self.props.ZIndex,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(.5, .5),

        [Roact.Ref] = self.ViewportRef
    }, {
        Camera = ViewportCamera
    })

    task.delay(1, self.PostUpdate, self)

    return Viewport
end

function Viewport2:PostUpdate()
    local ViewportObj = self.ViewportRef:getValue()
    local Camera = self.CameraRef:getValue()

    ViewportObj.CurrentCamera = Camera
end

function Viewport2:NewFocus(Model, Direction, DistanceFromCamera)
	local Camera = self.CameraRef:getValue()
	local Viewport = self.ViewportRef:getValue()

    if not Camera or not Viewport then
        return
    end
    
    Model = Model:Clone()

    self.CameraCFrame = CFrame.lookAt(
        (Model:GetPivot() + Direction * DistanceFromCamera).Position,
        Model:GetPivot().Position
    )
    Camera.CFrame = self.CameraCFrame

    Model.Parent = Viewport

    return true
end

return Viewport2