local _ = require "base.utils"
local wrap = require "libs.wrap"
local once = require "libs.once"
local flux = require "libs.flux"
local tick = require "libs.tick"
local coil = require "libs.coil"
local Class = require "base.class"

local Flow = Class:extend()

-- EXAMPLE
-- self.tick(2, self.wrap({x = -500}))
-- :tween(self, 1, {x = 100})
-- :wait(2, self.wrap({x = -100}))
-- :tween(self, 2, {x = 0}):delay(3)
-- :wait(1, self.wrap:test())

function Flow:new()
	self.wrap = wrap.new(self)
	if not self._ then
		self._ = self.wrap
	end

	if not self.F then
		self.F = self.wrap
	end
	self.once = once.new(self)
	self.useFlow = false
end

function Flow:initFlux()
	if self.flux then return end
	self.useFlow = true
	self.flux = flux.group()
	if not self.tick then
		self.tick = tick.group()
		self.tick._flux = self.flux
		self.flux._tick = self.tick
	end
end

function Flow:initTick()
	if self.tick then return end
	self.useFlow = true
	self.tick = tick.group()
	if not self.flux then
		self.flux = flux.group()
		self.flux._tick = self.tick
		self.tick._flux = self.flux
	end
end

function Flow:initCoil()
	if self.coil then return end
	self.useFlow = true
	self.coil = coil.group()
end

function Flow:update(dt)
	if self.callbacks and #self.callbacks > 0 then
		for i, v in _.ripairs(self.callbacks) do
			v()
			table.remove(self.callbacks, i)
		end
	end

	if not self.useFlow then return end
	if self.flux then
		self.flux:update(dt)
	end
	if self.tick then
		self.tick:update(dt)
	end
	if self.coil then
		self.coil:update(dt)
	end
end

function Flow:delay(t, f, args)
	if not self.tick then self:initTick() end
	if type(f) == "table" then
		return self.tick:delay(t or 1, function() for k, v in pairs(f) do _.set(self, k, v) end end)
	else
		return self.tick:delay(t or 1,
			function() if type(f) == "string" then self[f](self, unpack(args or {})) else f(unpack(args or {})) end end)
	end
end

function Flow:tween(obj, speed, properties, y)
	if not self.flux then self:initFlux() end
	if type(obj) == "number" then
		obj, speed, properties, y = self, obj, speed, properties
	end

	if type(properties) ~= "table" then
		local t = {}
		local x = properties
		if x then t.x = x end
		if y then t.y = y end
		properties = t
	end

	return self.flux:to(obj, speed, properties)
end

function Flow:event(f, t, l, e)
	if not self.coil then self:initCoil() end
	t = t or 0.1
	local random = type(t) == "table"
	return self.coil:add(function()
		local i = 0
		while (not l) or (i < l) do
			i = i + 1
			if f(i) then
				break
			end
			coil.wait(random and _.random(t[1], t[2]) or t)
		end
		if e then e() end
	end)
end

function Flow:cb(cb)
	if not self.callbacks then
		self.callbacks = {}
	end

	table.insert(self.callbacks, cb)
end

return Flow
