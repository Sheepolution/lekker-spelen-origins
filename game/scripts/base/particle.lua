local _ = require "base.utils"
local Entity = require "base.entity"

local Particle = Entity:extend("Particle")

-- TODO: Redo this class. Have a min-max variable for everything.

function Particle:new(x, y, flags)
	Particle.super.new(self, x, y)
	self.timer = 0
	if flags then
		for k, v in pairs(flags) do
			self[k] = v
		end
	end
	if self.maxSpeed then
		local speed = _.random(self.minSpeed or 0, self.maxSpeed)
		if self.circleSpread then
			self.angle = _.random(TAU)
			self:moveToAngle(self.angle, speed)
		end
	end
end

function Particle:update(dt)
	self:onUpdate(dt)
end

function Particle:onUpdate(dt)
	Particle.super.update(self, dt)
	self.timer = self.timer + dt

	if self.lifetime then
		self.lifetime = self.lifetime - dt
		if self.lifetime <= 0 then
			self:destroy()
		end
	end

	if self.alphaSpeed then
		self.alpha = self.alpha + self.alphaSpeed * dt
		if self.alpha <= 0 then
			self.alpha = 0
			self:destroy()
		end
	end

	if self.scaleSpeed then
		self.scale.x = self.scale.x + self.scaleSpeed * dt
		self.scale.y = self.scale.y + self.scaleSpeed * dt
		if self.scale.x <= 0 then
			self.scale.x = 0
			self:destroy()
		end
	end
end

return Particle
