local _ = require "base.utils"
local Point = require "base.point"
local Class = require "base.class"

local Movement = Class:extend("Movement")

local huge = math.huge
local abs = math.abs
local sign = _.sign

function Movement:new(vel, accel, drag, max, once)
	self.velocity = vel or Point(0, 0)
	self.accel = accel or Point(0, 0)
	self.drag = drag or Point(0, 0)

	self.maxVelocity = max or Point(huge, huge)

	self.once = once
end

local xy = { "x", "y" }
local pos = { x = 0, y = 0 }

function Movement:move(dt)
	pos.x, pos.y = 0, 0
	local do_drag = false

	for i, v in ipairs(xy) do
		local velocity = self.velocity[v]
		velocity = velocity + self.accel[v] * dt;

		if abs(velocity) > self.maxVelocity[v] then
			velocity = self.maxVelocity[v] * (velocity > 0 and 1 or -1);
		end

		pos[v] = pos[v] + velocity * dt;
		self.velocity[v] = velocity
		do_drag = do_drag or velocity ~= 0
	end

	if do_drag then
		self:applyDrag(dt)
	end

	return pos.x, pos.y
end

function Movement:applyDrag(dt)
	for i, v in ipairs(xy) do
		local velocity = self.velocity[v]
		local drag = self.drag[v]
		if sign(self.accel[v]) ~= sign(velocity) and drag ~= 0 then
			if (drag * dt > abs(velocity)) then
				velocity = 0
			else
				velocity = velocity + drag * dt * (velocity > 0 and -1 or 1);
			end
		end
		self.velocity[v] = velocity
	end

	if self.once then
		if self.velocity.x == 0 and self.velocity.y == 0 then
			self:destroy()
		end
	end
end

function Movement:destroy()
	self.destroyed = true
end

return Movement
