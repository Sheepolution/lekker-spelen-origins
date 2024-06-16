local HCbox = require "base.hcbox"
local Entity = require "base.entity"

local Bar = Entity:extend("Bar")

function Bar:new(...)
    Bar.super.new(self, ...)
    self:setImage("minigames/ufo/bar")
    self.rotation = .5
    self.isDangerous = true
    self.solid = 0
end

function Bar:done()
    self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x, self.y, self.width, self.height)
    self.angle = self.vertical and PI / 2 or 0
    self.startAngle = self.angle
    if self.reverse then
        self.rotation = -.5
    end
end

function Bar:update(dt)
    if self.scene.startedRace then
        Bar.super.update(self, dt)
        self.hcbox:update(dt)
    end
end

function Bar:onRaceReset()
    self.angle = self.startAngle
end

return Bar
