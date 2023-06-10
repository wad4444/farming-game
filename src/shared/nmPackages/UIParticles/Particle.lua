local Particle = {};

function Particle.new(element)
	local self = {};
	self.element = element;
	self.position = Vector2.new(0,0);
	self.starterPosition = UDim2.fromScale(0, 0)
	self.velocity = Vector2.new(0,0);
	self.age = 0;
	self.ticks = 0;
	self.maxAge = 1;
	self.isDead = false;

	return setmetatable(self, {__index = Particle});
end

function Particle:Update(delta, onUpdate)
	if self.age >= self.maxAge and self.maxAge > 0 then 
		self:Destroy()
		return;
	end;

	-- Update some properties
	self.ticks = self.ticks + 1;
	self.age = self.age + delta;	-- Make it a little older

	-- Callback
	onUpdate(self, delta)

	-- Apply the forces
	self.element.Position = UDim2.new(
		self.starterPosition.X.Scale, self.position.X,
		self.starterPosition.Y.Scale, self.position.Y
	);
end

function Particle:Destroy()
	self.isDead = true;
	self.element:Destroy();
end

return Particle;
