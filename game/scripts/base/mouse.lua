local _ = require "base.utils"
local Point = require "base.point"
local Input = require "base.input"

local Mouse = Input._class:extend()

Mouse:implement(Point)

Mouse.cursors = {}
Mouse.cursors.arrow = love.mouse.getSystemCursor("arrow")
Mouse.cursors.hand = love.mouse.getSystemCursor("hand")

function Mouse:new()
	Mouse.super.new(self)
	self._class = Mouse
	self.x = love.mouse.getX()
	self.y = love.mouse.getY()
	self.cursor = nil
end

function Mouse:update()
	local x, y = love.mouse.getPosition()
	x, y = self:toGameCoords(x, y)
	self.x = x
	self.y = y
	self.cursor = nil
end

function Mouse:isDown(...)
	return _.any({ ... },
		function(a) return self._custom[a] and _.any(self._custom[a], function(b) return love.mouse.isDown(b) end) end)
end

function Mouse:draw()
	love.graphics.circle("fill", self.x, self.y, 5, 25)
end

function Mouse:setCursor(cursor)
	self.cursor = cursor
end

function Mouse:_reset()
	Mouse.super._reset(self)
	local current = love.mouse.getCursor()
	if current == self.cursor then
		return
	else
		love.mouse.setCursor(self.cursor)
		self.cursor = Mouse.cursors.arrow
	end
end

function Mouse:set(x, y)
	Point.set(self, x, y)
	love.mouse.setPosition(x, y)
end

function Mouse:grab()
	love.mouse.setGrabbed(true)
end

function Mouse:release()
	love.mouse.setGrabbed(false)
end

function Mouse:is(a)
	return a == Mouse or a == Point
end

function Mouse:toGameCoords(x, y)
	local gx, gy = WIDTH, HEIGHT
	local wx, wy = love.graphics.getDimensions()
	local sx, sy = wx / gx, wy / gy
	local s = math.min(sx, sy)
	local ox, oy = 0, 0

	if sx > sy then
		ox = (wx - gx * s) / 2
	else
		oy = (wy - gy * s) / 2
	end

	return _.clamp((x - ox) / s, 0, WIDTH),
		_.clamp((y - oy) / s, 0, HEIGHT)
end

return Mouse()
