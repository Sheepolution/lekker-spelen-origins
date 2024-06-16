local Colors = require "base.colors"
local Sprite = require "base.sprite"

local Lamp = Sprite:extend("Lamp")

function Lamp:new(x, y, flipx, flipy)
    Lamp.super.new(self, x, y)
    self:setImage("bosses/panda/decoration/lamp")
    self.light = Sprite(0, 0, "bosses/panda/decoration/lamp_light")
    self.light.alpha = .15
    self.origin:set(0, 0)
    self.light.origin:set(0, 0)
    -- self.angle = angle
    self.flip.x = flipx
    self.flip.y = flipy

    self.timer = _.random(1)
    self.angleAround = false
end

function Lamp:update(dt)
    Lamp.super.update(self, dt)
    if self.angleAround then
        self.timer = self.timer + dt
        self.angle = math.sin(self.timer * PI) * .1 * _.boolsign(self.flip.x)
    end
end

function Lamp:draw()
    Lamp.super.draw(self)
    self.light:drawAsChild(self, { "angle", "flip" }, true, true)
end

function Lamp:randomColor()
    local color = Colors(_.pick({ "red", "blue", "green", "yellow" }))
    self:setColor(color)
    self.light:setColor(color)
end

function Lamp:randomAngle()
    self.angle = _.random(-.1, .1)
end

return Lamp
