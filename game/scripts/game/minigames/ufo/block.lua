local HCbox = require "base.hcbox"
local Entity = require "base.entity"

local Block = Entity:extend("Block")

function Block:new(...)
    Block.super.new(self, ...)
    self:setImage("minigames/ufo/block")
    self.pathIndex = 0
    self.solid = 0
    self.speed = 110
    self.isDangerous = true
    self.start = {
        x = self.x,
        y = self.y,
    }

    self.flip.x = _.coin()
    self.flip.y = _.coin()
end

function Block:done()
    table.insert(self.path, { x = self.x, y = self.y })

    for i, v in ipairs(self.path) do
        v.x = v.x + self.width / 2
        v.y = v.y + self.height / 2
    end

    local tween
    tween = function()
        self.pathIndex = self.pathIndex + 1
        if self.pathIndex > #self.path then
            self.pathIndex = 1
        end

        local coordinates = self.path[self.pathIndex]

        local distanceX = self:getDistanceX(coordinates)
        local distanceY = self:getDistanceY(coordinates)
        local t

        if distanceX > 0 then
            local duration = distanceX / self.speed
            t = self:tween(duration, { x = coordinates.x - self.width / 2 })
        end

        if distanceY > 0 then
            local duration = distanceY / self.speed
            t = self:tween(duration, { y = coordinates.y - self.height / 2 })
        end
        if t then
            t:oncomplete(self.tweenFunction):ease("linear"):delay(.5)
            self.currentTween = t
        end
    end

    self.tweenFunction = tween

    self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x, self.y, self.width, self.height)
end

function Block:update(dt)
    if self.scene.startedRace then
        Block.super.update(self, dt)
        self.hcbox:update(dt)
    end
end

function Block:onRaceStart()
    self.tweenFunction()
end

function Block:onRaceReset()
    self.x = self.start.x
    self.y = self.start.y
    if self.currentTween then
        self.currentTween:stop()
    end
    self.pathIndex = 0
end

return Block
