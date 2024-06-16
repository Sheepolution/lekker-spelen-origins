local _ = require "base.utils"
local HC = require "libs.HC"
local Sprite = require "base.sprite"
local Input = require "base.input"
local World = require "base.map.world"
local Camera = require "base.camera"
local Rect = require "base.rect"

local Scene = Sprite:extend("Scene")

function Scene:new(x, y, width, height)
	self.canvas = love.graphics.newCanvas(width or WIDTH, height or HEIGHT)
	self.canvas:setFilter(CONFIG.defaultGraphicsFilter, CONFIG.defaultGraphicsFilter)

	Scene.super.new(self, x, y, self.canvas)

	self.entities = list()
	self.overlay = list()
	self.underlay = list()
	self.particles = list()
	self.everything = list({ self.entities, self.particles, self.overlay, self.underlay })

	self.spatialHash = {}
	self.spatialHashSize = CONFIG.defaultSpatialHashSize

	self.backgroundColor = { 0, 0, 0 }
	self.backgroundAlpha = 1

	self.camera = Camera(0, 0, width or WIDTH, height or HEIGHT)
	self.camera:setWindow(0, 0, width or WIDTH, height or HEIGHT)

	self.fadeRect = Rect(0, 0, self.width, self.height)
	self.fadeRect:setColor(0, 0, 0)
	self.fadeRect.alpha = 0

	self.showEffects = true
	self.useStencil = false
end

function Scene:update(dt)
	if self.showScene then
		self.showScene:update(dt)
		return
	end

	self:removeEverythingDestroyed()

	self:updateEntities(dt)

	self:handleOverlap()

	for i, v in ipairs(self.underlay) do
		if v.update then
			v:update(dt)
		end
	end

	for i, v in ipairs(self.overlay) do
		if v.update then
			v:update(dt)
		end
	end

	Scene.super.update(self, dt)

	if self.map then
		self.map:update(dt)
	end

	if self.music then
		self.music:update(dt)
	end

	if self.camera then
		self:updateCamera(dt)
	end

	if DEBUG_INFO then
		DEBUG_INFO:addInfo(self.tag:sub(1, 10) .. " E", #self.entities)
		DEBUG_INFO:addInfo(self.tag:sub(1, 10) .. " O", #self.overlay)
	end
end

function Scene:updateEntities(dt)
	-- local everything_sorted_to_update = self:getEverythingSorted("updatePriority")
	-- for i, v in ipairs(everything_sorted_to_update) do
	-- 	if v.update and not v.destroyed then
	-- 		v:update(dt)
	-- 	end
	-- end

	for i, v in ipairs(self.entities) do
		if v.update and not v.destroyed then
			v:update(dt)
		end
	end

	for i, v in ipairs(self.particles) do
		if v.update and not v.destroyed then
			v:update(dt)
		end
	end
end

function Scene:updateCamera(dt)
	self.camera:update(dt)
end

function Scene:draw()
	if self.showScene then
		if self.effects and self.showEffects then
			self.effects(function()
				self.showScene:draw()
			end)
		else
			self.showScene:draw()
		end
		return
	end

	if not self.visible then
		return
	end

	love.graphics.push("all")
	if self.canvas then
		love.graphics.origin()
		love.graphics.setCanvas({ self.canvas, stencil = self.useStencil })
		love.graphics.clear(self.backgroundColor[1] / 255, self.backgroundColor[2] / 255, self.backgroundColor[3] / 255,
			self.backgroundAlpha)
	end

	self:drawInCanvas()

	love.graphics.pop()

	if self.canvas then
		if self.effects and self.showEffects then
			self.effects(function()
				self:drawCanvas()
			end)
		else
			self:drawCanvas()
		end
	end
end

function Scene:drawInCanvas()
	self.everythingSortedToDraw = self:getEverythingSorted("z")

	self:drawOutsideCamera()

	if self.camera then
		if self.showEffects and self.effectsCamera then
			self.effectsCamera(function()
				self.camera:draw(function()
					self:drawInCamera()
				end)
			end)
		else
			self.camera:draw(function()
				self:drawInCamera()
			end)
		end
	else
		-- local level = self.map:getCurrentLevel()
		-- love.graphics.push()
		-- love.graphics.translate(-level.x, -level.y)
		-- self:drawInCamera()
		-- love.graphics.pop()
	end

	for i, v in _.ripairs(_.sort(self.overlay, "z")) do
		v:draw()
	end
end

function Scene:drawCanvas()
	Scene.super.draw(self)
	self.fadeRect:draw()
end

function Scene:drawOutsideCamera()
	if self.backgroundImage then
		self.backgroundImage:draw()
	end

	for i, v in _.ripairs(_.sort(self.underlay, "z")) do
		v:draw()
	end
end

function Scene:drawInCamera()
	for i, v in ipairs(self:getEverythingSorted("z")) do
		if v.draw then
			v:draw()
		end
	end

	if DEBUG then
		if Input:isDown("tab") then
			for _1, v in pairs(self.spatialHash) do
				for _2, hash in pairs(v) do
					for i2 = 1, #hash - 1 do
						for j2 = i2 + 1, #hash do
							local a, b = hash[i2], hash[j2]
							if a.parent ~= b.parent and not (a.parent.tile and b.parent.tile) then
								local x1, y1 = a.bb.x + a.bb.width / 2, a.bb.y + a.bb.height / 2
								local x2, y2 = b.bb.x + b.bb.width / 2, b.bb.y + b.bb.height / 2
								love.graphics.setColor(1, .4, .4, .8)
								if (a.parent.tile or b.parent.tile) then
									love.graphics.setColor(.4, .4, 1, .3)
								end
								love.graphics.line(x1, y1, x2, y2)
								love.graphics.setColor(1, .4, .4)
							end
						end
					end
				end
			end

			self.entities:drawDebug()
			love.graphics.setColor(1, 1, 1)
			for i, v in pairs(self.spatialHash) do
				for j, w in pairs(v) do
					love.graphics.rectangle("line", (j - 1) * self.spatialHashSize, (i - 1) * self.spatialHashSize,
						self.spatialHashSize
						, self.spatialHashSize)
					love.graphics.print(tostring(#w), (j - 1) * self.spatialHashSize + self.spatialHashSize / 2,
						(i - 1) * self.spatialHashSize + self.spatialHashSize / 2)
				end
			end
		end
	end
end

function Scene:setBackgroundColor(r, g, b, a)
	if type(r) == "table" then
		self.backgroundColor = { r[1] or self.backgroundColor[1], r[2] or self.backgroundColor[2],
			r[3] or self.backgroundColor[3] }
		if g then
			self.backgroundAlpha = g
		elseif r[4] then
			self.backgroundAlpha = a
		end
	else
		if r then self.backgroundColor[1] = r end
		if g then self.backgroundColor[2] = g end
		if b then self.backgroundColor[3] = b end
		if a then
			self.backgroundAlpha = a
		end
	end
end

function Scene:setBackgroundAlpha(a)
	self.backgroundAlpha = a
end

function Scene:setBackgroundImage(path)
	self.backgroundImage = Sprite(0, 0, path)
end

function Scene:getEverythingSorted(k)
	local combined = {}
	for _, obj in ipairs(self.entities) do
		table.insert(combined, obj)
	end
	for _, obj in ipairs(self.particles) do
		table.insert(combined, obj)
	end

	table.sort(combined, function(a, b)
		local za, zb = a[k] or 0, b[k] or 0
		if za == zb then
			-- Handle Z-fighting by using unique ID for deterministic order
			return a.__id < b.__id
		end
		return za > zb
	end)

	return combined
end

-- TODO: Remove this or optimize it
-- Replace it with batteries sort function?
-- Sort on ID in case z is equal
function Scene:sort(sorted, exists, t, k)
	local z
	for _1, obj in ipairs(t) do
		z = obj[k] or 0
		if not exists[z] then
			exists[z] = true
			if #sorted == 0 then
				sorted[1] = { z, obj }
			elseif #sorted == 1 then
				if z > sorted[1][1] then
					table.insert(sorted, 1, { z, obj })
				else
					sorted[#sorted + 1] = { z, obj }
				end
			else
				local insert = false
				for i, v in ipairs(sorted) do
					if z > v[1] then
						table.insert(sorted, i, { z, obj })
						insert = true
						break
					end
				end
				if not insert then
					sorted[#sorted + 1] = { z, obj }
				end
			end
		else
			for i, v in ipairs(sorted) do
				if v[1] == z then
					v[#v + 1] = obj
				end
			end
		end
	end
end

function Scene:removeEverythingDestroyed()
	if #self.entities > 0 then self:removeDestroyed(self.entities) end
	if #self.particles > 0 then self:removeDestroyed(self.particles) end
	if #self.overlay > 0 then self:removeDestroyed(self.overlay) end
end

function Scene:removeDestroyed(t)
	t:filter_inplace(function(e) return not e.destroyed end)
end

function Scene:setMap(map, level, properties)
	self.map = World(self, map, level, properties)
end

function Scene:getMap(map)
	return self.map
end

function Scene:setLevel(id)
	return self.map:toLevel(id)
end

function Scene:getLevel()
	return self.map:getCurrentLevel()
end

function Scene:onChangingLevel(level)
	self.entities:filter_inplace(function(e) return not e.removeOnLevelChange end)
	self.overlay:filter_inplace(function(e) return not e.removeOnLevelChange end)
end

function Scene:addEntity(...)
	for i, v in ipairs({ ... }) do
		if self.entities:contains(v) then
			warning("Adding entity twice!")
			return
		end
		self:finishObject(v)
		self.entities:add(v)
	end
	return ({ ... })[1]
end

Scene.add = Scene.addEntity

function Scene:addOverlay(...)
	for i, v in ipairs({ ... }) do
		self:finishObject(v)
		self.overlay[#self.overlay + 1] = v
	end
	return ({ ... })[1]
end

function Scene:addUnderlay(...)
	for i, v in ipairs({ ... }) do
		self:finishObject(v)
		self.underlay[#self.underlay + 1] = v
	end
	return ({ ... })[1]
end

function Scene:removeEntity(v)
	if not v.scene then return end
	if v.interactable then
		v:resetHitboxes()
	end
	v.scene = nil
	self.entities:removeValue(v)
end

Scene.remove = Scene.removeEntity

function Scene:finishObject(obj)
	obj.scene = self
	if not obj.__done then
		obj:done()
		obj.__done = true
	end
end

function Scene:addParticle(class, ...)
	local Particles = require "head.particles"
	local p = Particles[class](...)
	p.scene = self
	return self.particles:add(p)
end

function Scene:findEntity(f)
	return self.entities:find(f)
end

function Scene:findEntities(f)
	return self.entities:filter(f)
end

function Scene:findEntitiesOfType(a, f)
	local t
	if f then
		t = self.entities:filter(function(x) return x:is(a) and f(x) end)
	else
		t = self.entities:filter(function(x) return x:is(a) end)
	end
	return t
end

function Scene:findEntityOfType(a, f)
	return self:findEntitiesOfType(a, f)[1]
end

function Scene:findEntitiesWithTag(a, f)
	local t
	if f then
		t = self.entities:filter(function(x) return x.tag == a and f(x) end)
	else
		t = self.entities:filter(function(x) return x.tag == a end)
	end
	return t
end

function Scene:findEntityWithTag(a, f)
	return self:findEntitiesWithTag(a, f)[1]
end

function Scene:findNearestEntity(p, f)
	local d = math.huge
	local d2, e
	for i, v in ipairs(self.entities:filter(f)) do
		d2 = v:getDistance(p)
		if d2 < d then
			e = v
			d = d2
		end
	end
	return e, d
end

function Scene:findNearestEntityOfType(p, a, f)
	local d = math.huge
	local d2, e
	for i, v in ipairs(self:findEntitiesOfType(a, f)) do
		d2 = v:getDistance(p)
		if d2 < d then
			e = v
			d = d2
		end
	end
	return e, d
end

function Scene:handleOverlap()
	local i = 0
	local leftovers = {}
	local nextLeftovers = {}
	local leftoverCount = 0
	local on_leftovers = false
	local cache = {}
	local done = {}

	for j, entity in ipairs(self.entities) do
		if not entity.destroyed and entity.interactable then
			entity:setSpatialHash()
		end
	end

	local max = 1000

	while true do
		i = i + 1

		for _1, v in pairs(self.spatialHash) do
			for _2, hash in pairs(v) do
				for j = 1, #hash - 1 do
					for k = j + 1, #hash do
						local a, b = hash[j], hash[k]
						if a and b and a.active and b.active
							and a.parent ~= b.parent
							and not (cache[a] and cache[a][b])
							and not (cache[b] and cache[b][a])
							and not (done[a] and done[a][b])
							and not (done[b] and done[b][a])
							and (not on_leftovers or ((leftovers[a] or leftovers[b]) or (a.parent.pushed or b.parent.pushed))) then
							if not cache[a] then
								cache[a] = {}
							end

							cache[a][b] = true

							local overlap, reserve, separated = a.parent:handleOverlap(b.parent, a, b, i == 1)

							if reserve then
								nextLeftovers[a] = true
								nextLeftovers[b] = true
								leftoverCount = leftoverCount + 2
							else
								if overlap then
									if not separated then
										if not done[a] then
											done[a] = {}
										end
										done[a][b] = true
									end

									if a.parent.pushed then
										a:setSpatialHash(self)
										a.parent.pushed = false
										nextLeftovers[a] = true
										leftoverCount = leftoverCount + 1
									end

									if b.parent.pushed then
										b:setSpatialHash(self)
										b.parent.pushed = false
										nextLeftovers[b] = true
										leftoverCount = leftoverCount + 1
									end
								end
							end
						end
					end
				end
			end
		end

		if leftoverCount == 0 then
			break
		end

		leftovers = nextLeftovers
		on_leftovers = true
		nextLeftovers = {}
		leftoverCount = 0
		cache = {}

		if i > max then
			warning("Max reached in overlap while loop!")
			break
		end
	end

	self:removeEmptySpatialHashes()

	for i, entity in ipairs(self.entities) do
		if not entity.destroyed and entity.interactable then
			entity:handleOverlapWatches()
		end
	end
end

function Scene:removeEmptySpatialHashes()
	for k, v in pairs(self.spatialHash) do
		for l, w in pairs(v) do
			if #w == 0 then
				v[l] = nil
			end
		end
		if _.count(v) == 0 then
			self.spatialHash[k] = nil
		end
	end
end

function Scene:getCoordsToSpatialHash(left, top, right, bottom)
	local x1, y1 = self:getNormalizedSpatialHashPosition(left, top)
	local x2, y2 = self:getNormalizedSpatialHashPosition(right, bottom)

	return x1, y1, x2, y2
end

function Scene:addHitboxToSpatialHash(hitbox, x1, y1, x2, y2)
	for i = y1, y2 do
		for j = x1, x2 do
			if not self.spatialHash[i] then self.spatialHash[i] = {} end
			if not self.spatialHash[i][j] then self.spatialHash[i][j] = {} end
			local hash = self.spatialHash[i][j]
			hash[#hash + 1] = hitbox
		end
	end
end

function Scene:removeHitboxFromSpatialHash(hitbox)
	for i = hitbox.hashCoords.y1, hitbox.hashCoords.y2 do
		for j = hitbox.hashCoords.x1, hitbox.hashCoords.x2 do
			if self.spatialHash[i] and self.spatialHash[i][j] then
				_.remove(self.spatialHash[i][j], hitbox)
			end
		end
	end
end

function Scene:getNormalizedSpatialHashPosition(x, y)
	x = math.floor(x / self.spatialHashSize)
	y = math.floor(y / self.spatialHashSize)
	return x + 1, y + 1
end

function Scene:getCamera()
	return self.camera
end

function Scene:setScene(scene)
	self.showScene = scene
	if self.showScene then
		self.showScene.scene = self
	end
	return scene
end

function Scene:fadeOut(duration, onComplete, fadeMusic)
	self.fadeRect.alpha = 0
	local tween = self:tween(self.fadeRect, duration or 1, { alpha = 1 })
	if onComplete then
		tween:oncomplete(function() self:cb(onComplete) end)
	end

	if self.music and fadeMusic ~= false then
		self.music:stop(duration or 1)
	end
end

function Scene:fadeIn(duration, onComplete, resumeMusic)
	self.fadeRect.alpha = 1
	local tween = self:tween(self.fadeRect, duration or 1, { alpha = 0 })
	if onComplete then
		tween:oncomplete(function() self:cb(onComplete) end)
	end

	if self.music and resumeMusic ~= false then
		self.music:resume(duration or 1)
	end
end

function Scene:addHC()
	self.HC = HC.new()
end

return Scene
