local _ = require "base.utils"
local Class = require "base.class"

local Point = Class:extend("Point")

function Point:new(x, y)
	Point.super.new(self)
	self.x = x or 0
	self.y = y and y or self.x
end

function Point:set(x, y)
	self.x = x or self.x
	self.y = y and y or x and x or self.y
end

function Point:setStart(x, y)
	if not self.start then
		self.start = Point()
	end

	self.start:set(self.x or x, self.y or y)
end

function Point:clone(p)
	self.x = p.x
	self.y = p.y
end

--If point overlaps with rect
function Point:overlaps(r)
	local x1, y1, x2, y2 = self.x, self.y, r.x, r.y
	return x1 > x2 and
		x1 < x2 + r.width and
		y1 > y2 and
		y1 < y2 + r.height
end

function Point:get()
	return self.x, self.y
end

function Point:getX()
	return self.x
end

function Point:getY()
	return self.y
end

function Point:destroy()
	self.destroyed = true
end

function Point:getDistance(p)
	return _.distance(self.x, self.y, p.x, p.y)
end

return Point
