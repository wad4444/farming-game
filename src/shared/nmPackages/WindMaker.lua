-- CLASS
local WindService = {}
WindService.__index = WindService

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- PATHS
local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFXPool = Assets:WaitForChild("VFXPool")

-- VARIABLES
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RNG = Random.new()

-- FUNCTIONS
function WindService.new(setting)
	local Object = {}
	setmetatable(Object, WindService)
	
	Object.Location = setting.Location or game.Workspace.Camera
	Object.Randomized = setting.Randomized or false
	Object.Velocity = setting.Velocity or Vector3.new(0.45, 0, 0)
	Object.Amount = setting.Amount or 10
	Object.Current = 0
	Object.Frequency = setting.Frequency or 0.5
	Object.Lifetime = setting.Lifetime or 2
	Object.Amplitude = setting.Amplitude or 0.35
	Object.Range = setting.Range or 50
	Object.Part = VFXPool.Wind
	Object.Time = setting.Time or nil
	Object.HeightOffset = setting.HeightOffset or 15
	
	return Object
end

-- METHODS
function WindService:Start()
	if self.Time then
		local Timer = tick()
		self.While = RunService.Heartbeat:Connect(function()
			if (tick() - Timer) >= self.Time then
				Timer += self.Time
				if self.Current < self.Amount then
					self:CreateWind()
				end
			end
		end)
	else
		self.While = RunService.Heartbeat:Connect(function()
			while self.Current < self.Amount do
				self:CreateWind()
			end
		end)
	end
end

function WindService:Stop()
	if self.Connection then
		if self.Connection.Connected then
			self.Connection:Disconnect()
		end
	end
	if self.While then
		if self.While.Connected then
			self.While:Disconnect()
		end
	end
end

function WindService:GetRandomPosition()
	if not Character.PrimaryPart then
		return
	end
	return Vector3.new(
		Character.PrimaryPart.Position.X + RNG:NextInteger(-self.Range, self.Range), 
		Character.PrimaryPart.Position.Y + RNG:NextInteger(self.HeightOffset, self.Range), -- Replace to: "1, self.Range / 1.5" or see more wind nearby.
		Character.PrimaryPart.Position.Z + RNG:NextInteger(-self.Range, self.Range)
	)
end

function WindService:CalculateSineWave(amp, x, freq, phase)
	return amp * math.sin((x / freq) + phase)
end

function WindService:FadeWind(part)
	for i = 0, 1, 0.01 do task.wait(0.01)
		part.Trail.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, i),
			NumberSequenceKeypoint.new(0.6, i),
			NumberSequenceKeypoint.new(1, 1),
		}
	end
	task.wait(0.1)
end

function WindService:CreateWind()
	local Part = self.Part:Clone()
	Part.Parent = self.Location
	Part.Position = self:GetRandomPosition()
	self.Current += 1
	
	-- CHECK RANDOM STATE:
	if self.Randomized then
		-- GET RANDOM VALUES:
		local Towards = Vector3.new(RNG:NextNumber(-self.Velocity.X, self.Velocity.X), RNG:NextNumber(-self.Velocity.Y, self.Velocity.Y), RNG:NextNumber(-self.Velocity.Z, -self.Velocity.Z))
		local Latency = RNG:NextNumber(self.Lifetime, self.Lifetime + RNG:NextNumber(0.5, 1.5))
		
		-- MOVEMENT:
		local Render = RunService.RenderStepped:Connect(function()
			local Formula = WindService:CalculateSineWave(self.Amplitude, tick(), self.Frequency, 0)
			Part.CFrame = Part.CFrame * CFrame.new(0, 0, Formula) + Towards
		end)
		
		-- CLEANUP:
		task.delay(Latency, function()
			WindService:FadeWind(Part)
			Render:Disconnect()
			Part:Destroy()
			self.Current -= 1
		end)
	else
		-- MOVEMENT:
		local Render = RunService.RenderStepped:Connect(function()
			local Formula = WindService:CalculateSineWave(self.Amplitude, tick(), self.Frequency, 0)
			Part.CFrame = Part.CFrame * CFrame.new(0, 0, Formula) + self.Velocity
		end)
		
		-- START ENDING:
		task.delay(self.Lifetime, function()
			WindService:FadeWind(Part)
			Render:Disconnect()
			Part:Destroy()
			self.Current -= 1
		end)
	end
end

return WindService