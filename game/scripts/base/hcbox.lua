local _ = require "base.utils"
local Class = require "base.class"
local Enum = require "libs.enum"

local HCbox = Class:extend("HCbox")
local Shape = Enum("Rectangle", "Circle", "Polygon")
HCbox.Shape = Shape

function HCbox:new(p, HC, shape, ...)
	self.parent = p
	self.HC = HC
	self:set(shape, ...)
end

function HCbox:update(dt)
	self.collider:setRotation(self.parent.angle + self.parent.angleOffset, self.parent.origin.x, self.parent.origin.y)
	local x, y = self.parent.x + self.parent.origin.x, self.parent.y + self.parent.origin.y
	self.collider:moveTo(x, y)
end

function HCbox:draw()
	love.graphics.setColor(0, 100, 200, 100)
	love.graphics.setLineWidth(2)
	self.collider:draw("line")
	love.graphics.setColor(255, 255, 255)
end

function HCbox:destroy()
	self.HC.remove(self.collider)
end

function HCbox:overlaps(e)
	if DEBUG_INFO then
		DEBUG_INFO:addCollisionCheck()
	end
	return self.collider:collidesWith(e.collider)
end

function HCbox:set(shape, ...)
	if self.collider then
		self.HC.remove(self.collider)
	end

	if shape == Shape.Rectangle then
		self.collider = self.HC:rectangle(...)
	elseif shape == Shape.Circle then
		self.collider = self.HC:circle(...)
	elseif shape == Shape.Polygon then
		self.collider = self.HC:polygon(...)
	end

	self.collider.hcbox = self
end

function HCbox:getCollider()
	return self.collider
end

return HCbox
