local Rect = require "base.rect"

local Hitbox = Rect:extend("Hitbox")

function Hitbox:new(p, name, x, y, width, height, private, centered)
	self.parent = p
	self.name = name

	if not x then
		x, y = 0, 0
		width, height = self.parent.width, self.parent.height
	elseif type(width) ~= "number" then
		if width ~= nil then
			private = width
		end
		width, height = x, y
		x, y = 0, 0
	end

	Hitbox.super.new(self, x, y, width, height)
	self.last = Rect()
	self.last:clone(self)
	self.flipRelative = { x = true, y = true }

	self.active = true
	self.private = private

	self.solid = true

	self.bb = {}
	self.lbb = {}

	if centered == nil then
		self.centered = true
	else
		self.centered = centered
	end

	self.hashCoords = {}

	self:setBoundingBox(true)

	-- Put any custom data in here
	self.data = {}
	self.id = _.random()
end

function Hitbox:update()
	self.last:clone(self)
end

function Hitbox:setBoundingBox(last)
	local first = not self.bb.x
	if not first and last then
		self:setLastBoundingBox()
	end

	if self.centered then
		self.bb.localX = self.flipRelative.x and (self.parent.flip.x and -self.x or self.x) or self.x
		self.bb.localY = self.flipRelative.y and (self.parent.flip.y and -self.y or self.y) or self.y

		self.bb.x = self.parent.x + self.parent.width * .5 + self.bb.localX - self.width * .5
		self.bb.y = self.parent.y + self.parent.height * .5 + self.bb.localY - self.height * .5
		self.bb.width = self.width or 0
		self.bb.height = self.height or 0

		self.bb.left = self.bb.x
		self.bb.right = self.bb.x + self.bb.width
		self.bb.top = self.bb.y
		self.bb.bottom = self.bb.y + self.bb.height
		self.bb.centerX = self.bb.x + self.bb.width * .5
		self.bb.centerY = self.bb.y + self.bb.height * .5
	else
		self.bb.localX = self.x
		self.bb.localY = self.y

		self.bb.x = self.parent.x + self.bb.localX
		self.bb.y = self.parent.y + self.bb.localY
		self.bb.width = self.width or 0
		self.bb.height = self.height or 0

		self.bb.left = self.bb.x
		self.bb.right = self.bb.x + self.bb.width
		self.bb.top = self.bb.y
		self.bb.bottom = self.bb.y + self.bb.height
		self.bb.centerX = self.bb.x + self.bb.width * .5
		self.bb.centerY = self.bb.y + self.bb.height * .5
	end

	if first and last then
		self:setLastBoundingBox()
	end

	self.changed = true
end

function Hitbox:setLastBoundingBox()
	self.lbb.localX = self.bb.localX
	self.lbb.localY = self.bb.localY
	self.lbb.x = self.bb.x
	self.lbb.y = self.bb.y
	self.lbb.width = self.bb.width
	self.lbb.height = self.bb.height
	self.lbb.left = self.bb.left
	self.lbb.right = self.bb.right
	self.lbb.top = self.bb.top
	self.lbb.bottom = self.bb.bottom
	self.lbb.centerX = self.bb.centerX
	self.lbb.centerY = self.bb.centerY
end

function Hitbox:reset()
	self.changed = false
end

function Hitbox:activate()
	if self.active then return end
	self.active = true
	self.changed = true
end

function Hitbox:deactivate()
	if not self.active then return end
	self.active = false
	self.changed = true
	self:resetSpatialHash(self.parent.scene)
end

function Hitbox:draw()
	if not self.active then return end

	if self.parent.tile then
		love.graphics.setColor(0, 1, 1, .2)
	else
		if self.solid then
			love.graphics.setColor(.8, .2, .2, .8)
		else
			love.graphics.setColor(.6, .6, .1, .8)
		end
	end

	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", self.bb.x, self.bb.y, self.bb.width, self.bb.height)
	love.graphics.setColor(255, 255, 255)
end

function Hitbox:overlaps(h, last)
	if DEBUG_INFO then
		DEBUG_INFO:addCollisionCheck()
	end

	local bb1 = last and self.lbb or self.bb
	local bb2 = last and h.lbb or h.bb

	return bb1.right > bb2.left and
		bb1.left < bb2.right and
		bb1.bottom > bb2.top and
		bb1.top < bb2.bottom
end

function Hitbox:overlapsX(h, last)
	if DEBUG_INFO then
		DEBUG_INFO:addCollisionCheck()
	end

	local bb1 = last and self.lbb or self.bb
	local bb2 = last and h.lbb or h.bb

	return bb1.right > bb2.left and
		bb1.left < bb2.right
end

function Hitbox:overlapsY(h, last)
	if DEBUG_INFO then
		DEBUG_INFO:addCollisionCheck()
	end

	local bb1 = last and self.lbb or self.bb
	local bb2 = last and h.lbb or h.bb

	return bb1.bottom > bb2.top and
		bb1.top < bb2.bottom
end

function Hitbox:touches(h, last)
	if DEBUG_INFO then
		DEBUG_INFO:addCollisionCheck()
	end

	local bb1 = last and self.lbb or self.bb
	local bb2 = last and h.lbb or h.bb

	return bb1.right >= bb2.left and
		bb1.left <= bb2.right and
		bb1.bottom >= bb2.top and
		bb1.top <= bb2.bottom
end

function Hitbox:getBoundingBox(last)
	return last and self.lbb or self.bb
end

function Hitbox:getX(last)
	return last and self.lbb.x or self.bb.x
end

function Hitbox:getY(last)
	return last and self.lbb.y or self.bb.y
end

Hitbox.left = Hitbox.getX

Hitbox.top = Hitbox.getY

function Hitbox:right(last)
	return last and self.lbb.right or self.bb.right
end

function Hitbox:bottom(last)
	return last and self.lbb.bottom or self.bb.bottom
end

function Hitbox:centerX(last)
	return last and self.lbb.centerX or self.bb.centerX
end

function Hitbox:centerY(last)
	return last and self.lbb.centerY or self.bb.centerY
end

function Hitbox:getLocalX(last)
	return last and self.lbb.localX or self.bb.localX
end

function Hitbox:getLocalY(last)
	return last and self.lbb.localY or self.bb.localY
end

function Hitbox:setSpatialHash(scene)
	if not self.active then return end
	if not self.changed and self.hashCoords.x1 then return end
	-- TODO: Add -1, +1, because else you will fall through tiles.
	-- This essentially places all tiles in extra hashes, which is bad.
	-- Check if you can find a better solution for this.
	-- Test by placing the tile aligned with the edge of hash.
	local x1, y1, x2, y2 = scene:getCoordsToSpatialHash(self.bb.left - 1, self.bb.top - 1, self.bb.right + 1,
		self.bb.bottom + 1)
	local coords = self.hashCoords
	if x1 ~= coords.x1 or y1 ~= coords.y1 or x2 ~= coords.x2 or y2 ~= coords.y2 then
		self:resetSpatialHash(scene)
		scene:addHitboxToSpatialHash(self, x1, y1, x2, y2)
		coords.x1, coords.y1, coords.x2, coords.y2 = x1, y1, x2, y2
	end
end

function Hitbox:resetSpatialHash(scene)
	if self.hashCoords.x1 then
		scene:removeHitboxFromSpatialHash(self)
	end
	self.hashCoords.x1 = nil
end

function Hitbox:destroy(scene)
	if scene then
		self:resetSpatialHash(scene)
	end
end

return Hitbox
