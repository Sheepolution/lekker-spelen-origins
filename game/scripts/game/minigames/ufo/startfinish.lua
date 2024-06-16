local HCbox = require "base.hcbox"
local Entity = require "base.entity"

local StartFinish = Entity:extend("StartFinish")

function StartFinish:new(...)
    StartFinish.super.new(self, ...)
    self:setImage("minigames/ufo/start_finish")
    self.z = 10
    self.solid = 0
end

function StartFinish:done()
    if self.vertical then
        self.origin:set(0)
        self.angle = PI / 2
        self.x = self.x + 32
        self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x + self.height * .25, self.y,
            self.height * .50,
            self.width)
    else
        self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x, self.y + self.height * .25,
            self.width,
            self.height * .50)
    end
end

function StartFinish:update(dt)
    StartFinish.super.update(self, dt)
end

function StartFinish:draw()
    StartFinish.super.draw(self)
end

return StartFinish
