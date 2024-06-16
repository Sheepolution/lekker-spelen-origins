local _ = require "base.utils"
local step = require "libs.step"
local Class = require "base.class"
local DebugInfo = Class:extend()

local function average(t, multiplier)
	multiplier = multiplier or 1
	return _.round(_.average(t) * multiplier, .001)
end

function DebugInfo:new()
	self.info = {}
	self.defaultInfoKeys = {
		"drawCalls",
		"memory",
		"fps",
		"update_ms",
		"draw_ms",
		"delta",
		"coll_checks",
	}

	self.infoKeys = _.copy(self.defaultInfoKeys)

	self.timer = step.new(1)
	self.timer:finish()

	self.refresh = false

	self.collisionChecks = 0
	self.collisionChecksList = {}

	self.startTime = 0
	self.updateTimeList = {}
	self.drawTimeList = {}

	self.font = love.graphics.newFont(12)

	self.objects = {
		entities = 0,
		scenery = 0,
		particles = 0
	}

	self.visible = false
end

function DebugInfo:preUpdate(dt)
	self.infoKeys = _.copy(self.defaultInfoKeys)
	self.startTime = love.timer.getTime()
end

function DebugInfo:postUpdate(dt)
	table.insert(self.collisionChecksList, self.collisionChecks)

	local updateTime = love.timer.getTime() - self.startTime
	table.insert(self.updateTimeList, updateTime)

	self.collisionChecks = 0
	self.refresh = self.timer(dt)
	if self.refresh then
		self.info.coll_checks = average(self.collisionChecksList)
		self.collisionChecksList = {}

		self.info.update_ms = average(self.updateTimeList, 1000)
		self.updateTimeList = {}

		for k, v in pairs(self.objects) do
			self.info[k] = v
		end
	end
	self.objects = {
		entities = 0,
		scenery = 0,
		particles = 0
	}
end

function DebugInfo:preDraw()
	if not self.visible then return end
	self.startTime = love.timer.getTime()
end

function DebugInfo:postDraw()
	if not self.visible then return end
	local drawTime = love.timer.getTime() - self.startTime
	table.insert(self.drawTimeList, drawTime)

	if self.refresh then
		self.info.draw_ms = average(self.drawTimeList, 1000)
		self.drawTimeList = {}

		self.info.memory = _.round(collectgarbage("count")) .. "kb"
		local stats = love.graphics.getStats()
		self.info.drawCalls = stats.drawcalls
		self.info.fps = love.timer.getFPS()
		self.info.delta = _.round(love.timer.getAverageDelta() * 1000, .0001)
	end

	love.graphics.origin()
	love.graphics.setColor(0, 0, 0, .8)
	love.graphics.rectangle("fill", 0, 0, 180, #self.infoKeys * 16 + 16)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(self.font)

	for i, v in ipairs(self.infoKeys) do
		local j = i
		if i > #self.defaultInfoKeys then
			j = j + 1
		end

		love.graphics.print(v .. ":", 5, -10 + 15 * j)
		love.graphics.print(tostring(self.info[v]) or 0, 120, -10 + 15 * j)
	end
end

function DebugInfo:addCollisionCheck(amount)
	self.collisionChecks = self.collisionChecks + (amount or 1)
end

function DebugInfo:setObjects(name, amount)
	self.objects[name] = self.objects[name] + amount
end

function DebugInfo:setEntities(amount)
	self:setObjects("entities", amount)
end

function DebugInfo:setScenery(amount)
	self:setObjects("scenery", amount)
end

function DebugInfo:setParticles(amount)
	self:setObjects("particles", amount)
end

function DebugInfo:addInfo(name, value)
	table.insert(self.infoKeys, name)
	self.info[name] = value
end

function DebugInfo:toggle()
	self.visible = not self.visible
end

return DebugInfo
