local _ = require "base.utils"
local Hitbox = require "base.hitbox"
local Movement = require "base.movement"
local AngularMovement = require "base.angularmovement"
local Point = require "base.point"
local Rect = require "base.rect"
local Sprite = require "base.sprite"

local Entity = Sprite:extend("Entity")

function Entity:new(x, y, img, w, h)
	Entity.super.new(self, x, y, img, w, h)
	self.movement = Movement()
	self.velocity = self.movement.velocity
	self.accel = self.movement.accel
	self.drag = self.movement.drag
	self.maxVelocity = self.movement.maxVelocity

	self.angularMovement = AngularMovement(self, self.angle)
	self.angularVelocity = self.angularMovement.velocity
	self.angularAccel = self.angularMovement.accel
	self.angularDrag = self.angularMovement.drag
	self.maxAngularVelocity = self.angularMovement.maxVelocity

	self._movementList = {}

	self.last = Rect(x, y, w, h)
	self.moved = false
	self.dead = false
	self.destroyed = false
	self.solid = 1
	self.bounce = Point(0, 0)
	self.bounceAccel = Point(-1, -1)
	self.moves = true
	self.speed = 100

	self.useGravity = true

	self.autoFlip = { x = true, y = false, accel = nil }
	self.autoAngle = false

	self.lifespan = 0

	self.updatePriority = 0

	self.separatePriority = Point(0, 0)
	self.immovable = false

	self.interactable = true

	self.hitboxList = {}

	self._collisionCopy = {}
	self._collisionCopy.changed = false
	self._collisionCopy.sp = Point()
	self._collisionCopy.immovable = { x = self.immovable, y = self.immovable }
	self._collisionCache = {}
	self._collisionInfo = {}
	self._collOverlapCache = {}

	self._overlaps = {}
	self._overlapWatches = {}
end

function Entity:postNew()
	self.last:clone(self)

	self._collisionCopy.sp:clone(self.separatePriority)
	self._collisionCopy.immovable = { x = self.immovable, y = self.immovable }

	if self.width > 0 and not self.hitbox then
		self.hitbox = self:addHitbox("solid", self.width, self.height)
	else
		self:setBoundingBox(true)
	end
end

function Entity:update(dt)
	self.moved = false
	self.pushed = false

	if self.gravity and self.useGravity then
		self.movement.accel.y = self.gravity
	end

	if self.interactable then
		for i, v in ipairs(self.hitboxList) do
			v:reset()
		end

		if self._collisionCopy.changed then
			self._collisionCopy.changed = false
			self._collisionCopy.sp:clone(self.separatePriority)
			self._collisionCopy.immovable.x = self.immovable
			self._collisionCopy.immovable.y = self.immovable
		end

		for k, e in pairs(self._overlapWatches) do
			for i, watch in ipairs(e) do
				watch.active = true
			end
		end
	end

	self.lifespan = self.lifespan + dt

	for i = #self._movementList, 1, -1 do
		if self._movementList[i].destroyed then
			table.remove(self._movementList, i)
		end
	end

	if self.x ~= self.last.x or self.y ~= self.last.y then
		self.moved = true
	end

	if self.moves then
		self:move(dt)
	end

	for i, v in ipairs(self.hitboxList) do
		v:update(dt)
	end

	Entity.super.update(self, dt)

	self:handleFlip()

	if self.x ~= self.last.x or self.y ~= self.last.y then
		self.moved = true
	end

	if self.moved then
		self:setBoundingBox(true)
	end
end

function Entity:draw()
	if self.autoAngle then
		self.angle = self:getVelocityAngle()
		if self.velocity.x < 0 then
			if self.autoFlip.y then
				self.flip.y = true
			end
		end
	end

	Entity.super.draw(self)
end

function Entity:drawDebug()
	for i, v in ipairs(self.hitboxList) do
		v:draw()
	end
end

function Entity:handleFlip()
	if self.autoFlip.x then
		if self.autoFlip.accel then
			if self.accel.x ~= 0 then
				self.flip.x = self.accel.x < 0
			end
		else
			if self.velocity.x ~= 0 then
				self.flip.x = self.velocity.x < 0
			end
		end
	end

	if self.autoFlip.y then
		if self.autoFlip.accel then
			if self.accel.y ~= 0 then
				self.flip.y = self.accel.y < 0
			end
		else
			if self.velocity.y ~= 0 then
				self.flip.y = self.velocity.y < 0
			end
		end
	end
end

function Entity:doFlip(axis)
	if axis then
		self.velocity[axis] = -self.velocity[axis]
	else
		self.velocity.x = -self.velocity.x
		self.velocity.y = -self.velocity.y
	end
end

function Entity:move(dt)
	self.last:clone(self)

	local len = #self._movementList

	if len == 0 and not self:isMoving() then
		return
	end

	local total_vx, total_vy = 0, 0

	if self.angularVelocity ~= 0 or self.angularAccel ~= 0 then
		total_vx, total_vy = self.angularMovement:move(dt)
	end

	local x, y = self.movement:move(dt)
	total_vx = total_vx + x
	total_vy = total_vy + y

	if len > 0 then
		for i, v in ipairs(self._movementList) do
			local mx, my = v:move(dt)
			total_vx = total_vx + mx
			total_vy = total_vy + my
		end
	end

	self.x = self.x + total_vx
	self.y = self.y + total_vy
end

function Entity:addMovement(velocity, accel, drag, max, once, axis)
	if type(velocity) == "table" and velocity.velocity then
		return self:addExistingMovement(velocity)
	end

	local m
	local t = type(axis)

	if t == "string" then
		m = Movement()
		m.velocity[axis] = velocity or 0
		m.accel[axis] = accel or 0
		m.drag[axis] = drag or 0
		m.maxVelocity[axis] = max or m.maxVelocity[axis]
		m.once = once
	elseif t == "number" then
		m = AngularMovement(nil, axis, velocity, accel, drag, max, once)
	else
		m = Movement(velocity, accel, drag, max, once)
	end

	self._movementList[#self._movementList + 1] = m
	return m
end

function Entity:addExistingMovement(m)
	for i, v in ipairs(self._movementList) do
		if v == m then
			return
		end
	end

	self._movementList[#self._movementList + 1] = m
	return m
end

function Entity:removeMovement(m)
	for i, v in ipairs(self._movementList) do
		if v == m then
			table.remove(self._movementList, i)
			break
		end
	end

	return m
end

function Entity:removeAllMovement()
	self._movementList = {}
end

function Entity:moveToDirection(flip, speed, axis, auto)
	axis = axis or "x"
	speed = speed or self.speed
	flip = flip or self.flip[axis]
	auto = auto == nil
	self.velocity[axis] = flip and -speed or speed
	if auto then
		self.flip[axis] = flip
	end
end

function Entity:moveToAngle(angle, speed)
	self.velocity.x = math.cos(angle or self.angle) * (speed or self.speed)
	self.velocity.y = math.sin(angle or self.angle) * (speed or self.speed)
end

function Entity:moveToEntity(e, speed, auto)
	local angle = self:getAngle(e)
	if auto then self.angle = angle end
	self:moveToAngle(angle, speed)
end

function Entity:getVelocity()
	local x, y = self.velocity.x, self.velocity.y
	for i, v in ipairs(self._movementList) do
		x = x + v.velocity.x
		y = y + v.velocity.y
	end
	return x, y
end

function Entity:getVelocityAngle()
	local angle = math.atan2(self.velocity.y, self.velocity.x)
	return angle
end

function Entity:stopMoving(axis)
	if axis then
		self.velocity[axis] = 0
		self.accel[axis] = 0
	else
		self.velocity:set(0)
		self.accel:set(0)
	end
	self.angularVelocity = 0
end

function Entity:isMoving(axis)
	if axis then
		local moves = self.moves and (self.velocity[axis] ~= 0 or self.accel[axis] ~= 0)
		if moves then return true end

		for i, v in ipairs(self._movementList) do
			if v.velocity[axis] ~= 0 or v.accel[axis] ~= 0 then
				return true
			end
		end
	else
		return self.moves and
			((self.velocity.x ~= 0 or self.velocity.y ~= 0) or (self.accel.x ~= 0 or self.accel.y ~= 0)) or
			(self.angularVelocity ~= 0 or self.angularAccel ~= 0)
	end
end

function Entity:teleport(x, y)
	self.last:clone(self)
	self.x = x or self.x
	self.y = y or self.y

	self:updatePosition()
end

function Entity:updatePosition()
	self.moved = true
	-- TODO: This can be done more efficiently
	self:setBoundingBox()
	self:setBoundingBox(true)
	self:setSpatialHash()
end

function Entity:kill()
	self.dead = true
end

function Entity:destroy()
	for i, hitbox in ipairs(self.hitboxList) do
		hitbox:destroy(self.scene)
	end

	if self.mapLevel then
		if self.mapPermanentDestruction then
			self.mapLevel:registerDestroyedEntity(self.mapEntityId)
		end
	end

	Entity.super.destroy(self)
end

function Entity:resetHitboxes()
	for i, hitbox in ipairs(self.hitboxList) do
		hitbox:resetSpatialHash(self.scene)
	end
end

function Entity:setRelativeVelocity(x, y)
	if x then
		self.velocity.x = self.flip.x and -x or x
	end
	if y then
		self.velocity.y = self.flip.y and -y or y
	end
end

function Entity:moveLeft(vel)
	self.velocity.x = -(vel or self.speed or 100)
end

function Entity:moveRight(vel)
	self.velocity.x = vel or self.speed or 100
end

function Entity:moveUp(vel)
	self.velocity.y = -(vel or self.speed or 100)
end

function Entity:moveDown(vel)
	self.velocity.y = vel or self.speed or 100
end

function Entity:accelLeft(vel)
	self.accel.x = -(vel or self.speed or 100)
end

function Entity:accelRight(vel)
	self.accel.x = vel or self.speed or 100
end

function Entity:accelUp(vel)
	self.accel.y = -(vel or self.speed or 100)
end

function Entity:accelDown(vel)
	self.accel.y = vel or self.speed or 100
end

function Entity:moveForwardHorizontally(vel)
	self.velocity.x = (vel or self.speed or 100) * (self.flip.x and -1 or 1)
end

function Entity:addHitbox(name, x, y, width, height, private, centered)
	if type(name) == "number" then
		x, y, width, height, private, centered, name = unpack({ name, x, y, width, height, private, "solid" })
	end

	local hb = Hitbox(self, name, x, y, width, height, private, centered)
	table.insert(self.hitboxList, hb)

	if not self.hitbox then self.hitbox = hb end

	return hb
end

function Entity:clearHitboxes()
	for i, v in ipairs(self.hitboxList) do
		v:destroy(self.scene)
	end

	self.hitboxList = {}
end

function Entity:countHitboxes()
	return #self.hitboxList
end

function Entity:setBoundingBox(last)
	for i, v in ipairs(self.hitboxList) do
		v:setBoundingBox(last)
	end
end

function Entity:setSpatialHash()
	if not self.scene then return end
	if #self.hitboxList == 0 then return end
	if (not self.moved and not self.pushed) and self.hitboxList[1].hashCoords.x1 then return end

	for i, hitbox in ipairs(self.hitboxList) do
		hitbox:setSpatialHash(self.scene)
	end
end

function Entity:hasListClass(t, e)
	if self.WORST or e.WORST then
		print("????")
	end
	local mt = getmetatable(e)
	while mt do
		if t[mt] then
			return true
		end
		mt = getmetatable(mt)
	end
	return false
end

function Entity:overlappable(e)
	if self == e
		or self.dead or e.dead
		or self.destroyed or e.destroyed then
		return false
	end

	if self.tile and e.tile then
		return false
	end

	if self.exclusiveOverlap then
		local my_cache = self.exclusiveOverlapCache[e.__uuid]
		if my_cache ~= nil then
			return my_cache
		end

		self.exclusiveOverlapCache[e.__uuid] = self:hasListClass(self.exclusiveOverlap, e)

		return self.exclusiveOverlapCache[e.__uuid]
	end

	if e.exclusiveOverlap then
		local my_cache = e.exclusiveOverlapCache[self.__uuid]
		if my_cache ~= nil then
			return my_cache
		end

		e.exclusiveOverlapCache[self.__uuid] = e:hasListClass(e.exclusiveOverlap, self)

		return e.exclusiveOverlapCache[self.__uuid]
	end

	if not self.ignoreOverlap and not e.ignoreOverlap then
		return true
	end

	if not self.ignoreOverlapCache then
		getmetatable(self).ignoreOverlapCache = {}
	end

	if not e.ignoreOverlapCache then
		getmetatable(e).ignoreOverlapCache = {}
	end

	local my_cache = self.ignoreOverlapCache[e.__uuid]
	if my_cache ~= nil then
		return not my_cache
	end

	local their_cache = e.ignoreOverlapCache[self.__uuid]
	if their_cache ~= nil then
		return not their_cache
	end

	self.ignoreOverlapCache[e.__uuid] = self.ignoreOverlap and self:hasListClass(self.ignoreOverlap, e)
	e.ignoreOverlapCache[self.__uuid] = e.ignoreOverlap and e:hasListClass(e.ignoreOverlap, self)

	return not (self.ignoreOverlapCache[e.__uuid] or e.ignoreOverlapCache[self.__uuid])
end

function Entity:overlaps(e, myHitbox, theirHitbox)
	if e == self then return false end
	if not myHitbox or not theirHitbox then return false end
	if myHitbox:overlaps(theirHitbox) then
		if (not self.extraOverlapCheck or self:extraOverlapCheck(e, myHitbox, theirHitbox))
			and (not e.extraOverlapCheck or e:extraOverlapCheck(self, theirHitbox, myHitbox)) then
			return true
		end
	end
end

function Entity:simpleOverlaps(e)
	return Rect.overlaps(self, e)
end

function Entity:onOverlap(c)
	-- 0 = Can't collide with this
	-- 1 = Only collides with 2
	-- 2 = Collides with 1 and 2.
	if self.destroyed or c.e.destroyed then return false end
	if self.solid == 0 or c.e.solid == 0 then return false end
	if self.solid == 2 or c.e.solid == 2 then
		return not
			(
				(self.ignoreCollision and self:hasListClass(self.ignoreCollision, c.e)) or
				(c.e.ignoreCollision and self:hasListClass(c.e.ignoreCollision, self)))
	end
end

function Entity:collectCollisionInfo(e, myHitbox, theirHitbox)
	local ci = self._collisionInfo
	ci.e = e
	ci.myHitbox = myHitbox
	ci.theirHitbox = theirHitbox

	ci.hisTop = myHitbox.lbb.bottom <= theirHitbox.lbb.top
	if ci.hisTop then
		ci.hisBottom = false
	else
		ci.hisBottom = myHitbox.lbb.top >= theirHitbox.lbb.bottom
	end

	ci.hisLeft = myHitbox.lbb.right <= theirHitbox.lbb.left
	if ci.hisLeft then
		ci.hisRight = false
	else
		ci.hisRight = myHitbox.lbb.left >= theirHitbox.lbb.right
	end

	ci.myBottom = ci.hisTop
	ci.myTop = ci.hisBottom
	ci.myLeft = ci.hisRight
	ci.myRight = ci.hisLeft

	local cb = e._collisionInfo
	cb.e = self
	cb.myHitbox = theirHitbox
	cb.theirHitbox = myHitbox
	cb.hisTop = ci.myTop
	cb.hisBottom = ci.myBottom
	cb.hisLeft = ci.myLeft
	cb.hisRight = ci.myRight
	cb.myTop = ci.hisTop
	cb.myBottom = ci.hisBottom
	cb.myLeft = ci.hisLeft
	cb.myRight = ci.hisRight
end

function Entity:handleOverlap(e, myHitbox, theirHitbox, ignoreCorners)
	if self == e
		or self.dead or e.dead
		or self.destroyed or e.destroyed then
		return false
	end

	if self.tile and e.tile then
		return false
	end

	if not self:overlappable(e) then return end

	local overlap = self:overlaps(e, myHitbox, theirHitbox)

	if not overlap then
		return false, false, false
	end

	self:collectCollisionInfo(e, myHitbox, theirHitbox)

	if self._overlapWatches[e] then
		self:handleWatchedOverlap(e)
	end

	if e._overlapWatches[self] then
		e:handleWatchedOverlap(self)
	end

	if ignoreCorners then
		local ci = self._collisionInfo
		if (ci.myBottom or ci.myTop) and (ci.myLeft or ci.myRight) then
			return true, true, false
		end
	end

	local a, b

	if not theirHitbox.private then
		a = self:onOverlap(self._collisionInfo)
	end

	if not myHitbox.private then
		b = e:onOverlap(e._collisionInfo)
	end

	if self.dead or e.dead then return true, false, false end

	if a == nil and not theirHitbox.private then
		a = Entity.onOverlap(self, self._collisionInfo)
	end

	if b == nil and not myHitbox.private then
		b = Entity.onOverlap(e, e._collisionInfo)
	end

	if a and b then
		if myHitbox.solid and theirHitbox.solid then
			self:handleSeparation(self._collisionInfo)
			return true, false, true
		end
	end

	return true, false, false
end

function Entity:watchOverlap(info, myType, theirType, notouch)
	if not self._overlapWatches[info.e] then
		self._overlapWatches[info.e] = {}
	end

	table.insert(self._overlapWatches[info.e], {
		info = {
			e = info.e,
			myHitbox = info.myHitbox,
			theirHitbox = info.theirHitbox
		},
		myType = myType or 0,
		theirType or 0,
		notouch = notouch,
		active = false
	})
end

function Entity:handleWatchedOverlap(e)
	local info = self._collisionInfo

	for i, watch in _.ripairs(self._overlapWatches[e]) do
		local skip = false
		if not watch.active then
			skip = true
		end

		if not skip then
			if watch.myType == 1 then
				if info.myHitbox.name ~= watch.myHitbox.name then
					skip = true
				end
			elseif watch.myType == 2 then
				if info.myHitbox ~= watch.myHitbox then
					skip = true
				end
			end
		end

		if not skip then
			if watch.theirType == 1 then
				if info.theirHitbox.name ~= watch.theirHitbox.name then
					skip = true
				end
			elseif watch.theirType == 2 then
				if info.theirHitbox ~= watch.theirHitbox then
					skip = true
				end
			end
		end

		if not skip then
			table.remove(self._overlapWatches[e], i)
		end
	end
end

function Entity:handleOverlapWatches()
	for k, e in pairs(self._overlapWatches) do
		for i, watch in _.ripairs(e) do
			if watch.active then
				local skip = false
				if watch.notouch then
					if watch.info.myHitbox:touches(watch.info.theirHitbox) then
						skip = true
					end
				end
				if not skip then
					self:onLeavingOverlap(watch.info)
					table.remove(e, i)
				end
			end
		end

		if #e == 0 then
			self._overlapWatches[k] = nil
		end
	end
end

function Entity:onLeavingOverlap(info)
end

function Entity:handleSeparation(collisionInfo)
	local e = collisionInfo.e
	local axis = (collisionInfo.hisRight or collisionInfo.hisLeft) and "x" or "y"

	local size = axis == "x" and "width" or "height"

	local myCollisionCopy = self._collisionCopy
	local theirCollisionCopy = e._collisionCopy

	local sim = self.immovableObjects and self:hasListClass(self.immovableObjects, e)
	local eim = e.immovableObjects and self:hasListClass(e.immovableObjects, self)

	local sc = self.separationCheck and self:separationCheck(self._collisionInfo) or 0
	local ec = e.separationCheck and e:separationCheck(e._collisionInfo) or 0

	if sc >= ec then
		if (sc > ec)
			or (sim or myCollisionCopy.immovable[axis])
			or (not (eim or theirCollisionCopy.immovable[axis])
				and myCollisionCopy.sp[axis] >= theirCollisionCopy.sp[axis]) then
			local moveBack
			if axis == "x" then
				if not collisionInfo.myLeft and not collisionInfo.myRight then
					moveBack = collisionInfo.theirHitbox.bb.centerX < collisionInfo.myHitbox.bb.centerX
				else
					moveBack = collisionInfo.myLeft
				end
			else
				if not collisionInfo.myTop and not collisionInfo.myBottom then
					moveBack = collisionInfo.theirHitbox.bb.centerY < collisionInfo.myHitbox.bb.centerY
				else
					moveBack = collisionInfo.myTop
				end
			end

			if self:separate(collisionInfo, axis, size, moveBack) then
				e:onSeparate(self, e._collisionInfo)
			end
			return
		end
	end

	e:handleSeparation(e._collisionInfo)
end

function Entity:separate(collisionInfo, axis, size, moveBack)
	local myCollisionCopy = self._collisionCopy
	local theirCollisionCopy = collisionInfo.e._collisionCopy
	if myCollisionCopy.immovable[axis] and theirCollisionCopy.immovable[axis] then
		return
	end

	local e = collisionInfo.e
	local myHitbox = collisionInfo.myHitbox
	local theirHitbox = collisionInfo.theirHitbox

	if moveBack then
		e[axis] = e[axis] - (theirHitbox.bb[axis] + theirHitbox.bb[size] - myHitbox.bb[axis])
	else
		e[axis] = e[axis] + (myHitbox.bb[axis] + myHitbox.bb[size] - theirHitbox.bb[axis])
	end

	return true
end

function Entity:onSeparate(e, collisionInfo)
	local axis = (collisionInfo.hisRight or collisionInfo.hisLeft) and "x" or "y"
	self.velocity[axis] = self.velocity[axis] * -self.bounce[axis]
	self.accel[axis] = self.accel[axis] * -self.bounceAccel[axis]

	if math.abs(self.velocity[axis]) < 1 then self.velocity[axis] = 0 end
	self._collisionCopy.sp[axis] = e._collisionCopy.sp[axis] + 1
	self._collisionCopy.changed = true
	self._collisionCopy.immovable[axis] = e._collisionCopy.immovable[axis] or
		(e.immovableObjects and self:hasListClass(e.immovableObjects, self))
	self.pushed = true
	self:setBoundingBox()
end

function Entity:lookAt(e, axis, noVelocityChange)
	if not axis then axis = "x" end
	local axisUpper = axis:upper()

	if self["center" .. axisUpper](self) < e["center" .. axisUpper](e) then
		self.flip[axis] = false
		if not noVelocityChange then
			self.velocity[axis] = math.abs(self.velocity[axis])
		end
	else
		self.flip[axis] = true
		if not noVelocityChange then
			self.velocity[axis] = -math.abs(self.velocity[axis])
		end
	end
end

function Entity:lookAway(e, axis, noVelocityChange)
	if not axis then axis = "x" end
	local AXIS = axis:upper()

	if self["center" .. AXIS](self) < e["center" .. AXIS](e) then
		self.flip[axis] = true
		if not noVelocityChange then
			self.velocity[axis] = -math.abs(self.velocity[axis])
		end
	else
		self.flip[axis] = false
		if not noVelocityChange then
			self.velocity[axis] = math.abs(self.velocity[axis])
		end
	end
end

function Entity:isLookingAt(e, axis)
	if not axis then axis = "x" end
	local AXIS = axis:upper()

	if self["center" .. AXIS](self) < e["center" .. AXIS](e) then
		return not self.flip[axis]
	else
		return self.flip[axis]
	end
end

function Entity:addExclusiveOverlap(...)
	if not self.exclusiveOverlap then
		self.exclusiveOverlap = {}
		self.exclusiveOverlapCache = {}
	else
		local raw = rawget(self, "exclusiveOverlap")
		if not raw then
			raw = {}
			for k, v in pairs(self.exclusiveOverlap) do
				raw[k] = v
			end
		end
		self.exclusiveOverlap = raw
		self.exclusiveOverlapCache = {}
	end

	for i, v in ipairs({ ... }) do
		self.exclusiveOverlap[v] = true
	end
end

function Entity:addIgnoreOverlap(...)
	if not self.ignoreOverlap then
		self.ignoreOverlap = {}
		self.ignoreOverlapCache = {}
	else
		local raw = rawget(self, "ignoreOverlap")
		if not raw then
			raw = {}
			for k, v in pairs(self.ignoreOverlap) do
				raw[k] = v
			end
		end
		self.ignoreOverlap = raw
	end

	for i, v in ipairs({ ... }) do
		self.ignoreOverlap[v] = true
	end
end

function Entity:addIgnoreCollision(...)
	if not self.ignoreCollision then
		self.ignoreCollision = {}
		self.ignoreCollisionCache = {}
	else
		local raw = rawget(self, "ignoreCollision")
		if not raw then
			raw = {}
			for k, v in pairs(self.ignoreCollision) do
				raw[k] = v
			end
		end
		self.ignoreCollision = raw
	end

	for i, v in ipairs({ ... }) do
		self.ignoreCollision[v] = true
	end
end

function Entity:addImmovableObjects(...)
	if not self.immovableObjects then
		self.immovableObjects = {}
	else
		local raw = rawget(self, "immovableObjects")
		if not raw then
			raw = {}
			for k, v in pairs(self.immovableObjects) do
				raw[k] = v
			end
		end
		self.immovableObjects = raw
	end

	for i, v in ipairs({ ... }) do
		self.immovableObjects[v] = true
	end
end

function Entity:emit(class, x, y, ...)
	x = x or 0
	y = y or 0
	if self.scene then
		return self.scene:addParticle(class, self:centerX() + x, self:centerY() + y, ...)
	end
end

return Entity
