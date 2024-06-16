local _ = require "base.utils"
local Class = require "base.class"

local AngularMovement = Class:extend("Movement")

local huge = math.huge
local abs = math.abs
local sign = _.sign
local cos, sin = math.cos, math.sin

function AngularMovement:new(parent, angle, vel, accel, drag, max, once)
	self.parent = parent

	self.angle = angle or 0

	self.velocity = vel or 0
	self.accel = accel or 0
	self.drag = drag or 0

	self.maxVelocity = max or huge

	self.once = once
	if parent then
		parent.angularVelocity = self.velocity
		parent.angularAccel = self.accel
		parent.angularDrag = self.drag
		parent.angularMaxVelocity = self.maxVelocity
	end
end

function AngularMovement:move(dt)
	if self.parent then
		self.angle = self.parent.angle
		self.velocity = self.parent.angularVelocity
		self.accel = self.parent.angularAccel
		self.drag = self.parent.angularDrag
		self.maxVelocity = self.parent.maxAngularVelocity
	end

	local velocity = self.velocity
	velocity = velocity + self.accel * dt;

	if abs(velocity) > self.maxVelocity then
		velocity = self.maxVelocity * (velocity > 0 and 1 or -1);
	end

	local x = cos(self.angle) * self.velocity * dt
	local y = sin(self.angle) * self.velocity * dt

	if self.velocity ~= 0 then
		self:applyDrag(dt)
	end

	if self.parent then
		self.parent.angularVelocity = self.velocity
		self.parent.angularAccel = self.accel
		self.parent.angularDrag = self.drag
		self.parent.angularMaxVelocity = self.maxVelocity
	end

	return x, y
end

function AngularMovement:applyDrag(dt)
	local velocity = self.velocity
	local drag = self.drag

	if sign(self.accel) ~= sign(velocity) and drag ~= 0 then
		if (drag * dt > abs(velocity)) then
			velocity = 0;
			if self.once then
				self:destroy()
			end
		else
			velocity = velocity + drag * dt * (velocity > 0 and -1 or 1);
		end
	end

	self.velocity = velocity
end

function AngularMovement:destroy()
	self.destroyed = true
end

return AngularMovement
