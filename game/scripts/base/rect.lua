local _ = require "base.utils"
local Mouse = require "base.mouse"
local Point = require "base.point"

local Rect = Point:extend("Rectangle")

function Rect:new(x, y, width, height)
	Rect.super.new(self, x, y)
	self.width = width or 0
	self.height = height == nil and self.width or height
	self._color = { 255, 255, 255 }
	self.alpha = 1
	self.z = 0
	self.visible = true
	self._hasColor = false
end

function Rect:draw(mode, x, y, width, height)
	if not self.visible then return end
	love.graphics.setColor(self._color[1], self._color[2], self._color[3], self.alpha)
	love.graphics.rectangle(mode or self.mode or "fill", self.x, self.y, self.width, self.height, self.radius or 0)
	love.graphics.setColor(1, 1, 1, 1)
end

function Rect:drawAsChild(p)
	local parent = p or self.parent
	assert(parent, "Please assign a parent", 2)
	if parent then
		love.graphics.translate(parent.x, parent.y)
		self:draw()
		love.graphics.translate(-parent.x, -parent.y)
	end
end

function Rect:setColor(r, g, b, a)
	if type(r) == "table" then
		self._color = { r[1] / 255 or self._color[1], r[2] / 255 or self._color[2], r[3] / 255 or self._color[3] }
		if g then
			self.alpha = g
		elseif r[4] then
			self.alpha = a
		end
	else
		if r then self._color[1] = r / 255 end
		if g then self._color[2] = g / 255 end
		if b then self._color[3] = b / 255 end
		if a then
			self.alpha = a
		end
	end

	self._hasColor = self._color[1] + self._color[2] + self._color[3] + self.alpha < 4
end

function Rect:getColor()
	local r, g, b = unpack(self._color)
	return r * 255, g * 255, b * 255, self.alpha
end

function Rect:setAlpha(a)
	self.alpha = a
end

function Rect:getAlpha()
	return self.alpha
end

function Rect:set(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width or self.width
	self.height = height and height or width and width or self.height
end

function Rect:setStart(x, y, width, height)
	if not self.start then
		self.start = Rect()
	end

	self.start:set(self.x or x, self.y or y, self.width or width, self.height or height)
end

function Rect:resetToStart()
	self:clone(self.start)
end

function Rect:get()
	return self.x, self.y, self.width, self.height
end

function Rect:clone(r)
	self.x = r.x
	self.y = r.y
	if r.width then
		self.width = r.width
		self.height = r.height
	end
end

--If rect overlaps with rect or point
function Rect:overlaps(r)
	return self.x + self.width > r.x and
		self.x < r.x + (r.width or 0) and
		self.y + self.height > r.y and
		self.y < r.y + (r.height or 0)
end

function Rect:overlapsX(r)
	return self.x + self.width > r.x and
		self.x < r.x + (r.width or 0)
end

function Rect:overlapsY(r)
	return self.y + self.height > r.y and
		self.y < r.y + (r.height or 0)
end

function Rect:insideOf(r)
	return self.x > r.x and
		self.x + self.width < r.x + (r.width or 0) and
		self.y > r.y and
		self.y + self.height < r.y + (r.height or 0)
end

function Rect:touches(r)
	return self.x + self.width >= r.x and
		self.x <= r.x + (r.width or 0) and
		self.y + self.height >= r.y and
		self.y <= r.y + (r.height or 0)
end

function Rect:overlapsPointReal(px, py)
	local x, y = self:getRealX(), self:getRealY()
	return x + self.width > px and
		x < px and
		y + self.height > py and
		y < py
end

function Rect:overlapsMouse()
	return self:overlapsPointReal(Mouse.x, Mouse.y)
end

function Rect:getRealX()
	if self.scene then
		return self.x + self.scene:getRealX()
	else
		return self.x or 0
	end
end

function Rect:getRealY()
	if self.scene then
		return self.y + self.scene:getRealY()
	else
		return self.y or 0
	end
end

function Rect:left(val)
	if val then self.x = val end
	return self.x
end

function Rect:right(val)
	if val then self.x = val - self.width end
	return self.x + self.width
end

function Rect:top(val)
	if val then self.y = val end
	return self.y
end

function Rect:bottom(val)
	if val then self.y = val - self.height end
	return self.y + self.height
end

function Rect:centerX(val)
	if val then self.x = val - self.width / 2 end
	return self.x + self.width / 2
end

function Rect:centerY(val)
	if val then self.y = val - self.height / 2 end
	return self.y + self.height / 2
end

function Rect:center(x, y)
	if x then self.x = x - self.width / 2 end
	if y then self.y = y - self.height / 2 end
	return self.x + self.width / 2, self.y + self.height / 2
end

function Rect:centerToScene()
	if not self.scene then return self:centerToScreen() end
	return self:center(self.scene.width / 2, self.scene.height / 2)
end

function Rect:centerToScreen()
	return self:center(WIDTH / 2, HEIGHT / 2)
end

function Rect:getDistance(r)
	return _.distance(self.x + self.width / 2, self.y + self.height / 2, r.x + (r.width and r.width / 2 or 0),
		r.y + (r.height and r.height / 2 or 0))
end

function Rect:getDistanceX(r)
	return math.abs((self.x + self.width / 2) - (r.x + (r.width and r.width / 2 or 0)))
end

function Rect:getDistanceY(r)
	return math.abs((self.y + self.width / 2) - (r.y + (r.width and r.width / 2 or 0)))
end

function Rect:getAngle(r)
	return _.angle(self.x + self.width / 2, self.y + self.height / 2, r.x + (r.width and r.width / 2 or 0),
		r.y + (r.height and r.height / 2 or 0))
end

function Rect:getAngleToPoint(x, y)
	return _.angle(self.x + self.width / 2, self.y + self.height / 2, x, y)
end

function Rect:isBelow(r)
	return self.y + self.height / 2 > r.y + r.height
end

function Rect:isAbove(r)
	return self.y + self.height / 2 < r.y + r.height / 2
end

return Rect
