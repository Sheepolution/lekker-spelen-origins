local Point = require "base.point"
local Input = require "base.input"
local Sprite = require "base.entity"

local Lightbulb = Sprite:extend("Lightbulb")

function Lightbulb:new(...)
    Lightbulb.super.new(self, ...)
    self:setImage("decoration/lightbulb", true)
    self.ropeLength = 150 / 100
    self.angle = PI / 50
    self.angularSpeed = 0
    self.g = 9.8 * .2

    self.solid = 0
    self.anim:set("on")

    self.swinging = true

    self.start = Point(self:center())
    self.bounce.y = .3

    self:addHitbox(8, 8)

    self.broken = false

    self.blinkTimer = step.every(2, 5)
    self.z = -2
end

function Lightbulb:done()
    Lightbulb.super.done(self)
    self.lightSource = self.scene:addLightSource(self, 0)
    self.lightSource.visible = false
end

function Lightbulb:startUp()
    self:tween(self.lightSource, 1, { radius = 50 })
        :onstart(function()
            self.lightSource.visible = true
        end)
end

function Lightbulb:update(dt)
    if self.swinging then
        -- Calculate the angular acceleration (Euler's method)
        local angularAcc = -self.g / self.ropeLength * self.angle

        -- Update the angular speed
        self.angularSpeed = self.angularSpeed + angularAcc * dt

        -- Update the angle
        self.angle = self.angle + self.angularSpeed * dt

        -- Calculate the offsets based on the updated angle
        self.offset.x = self.ropeLength * -math.sin(self.angle) * 100  -- Convert back to pixels
        self.offset.y = -self.ropeLength * -math.cos(self.angle) * 100 -- Convert back to pixels

        if self.blinkTimer(dt) then
            self.anim:set("off")
            self:delay(.1, function()
                self.anim:set("on")
            end)
        end
    end

    Lightbulb.super.update(self, dt)

    self.lightSource:center(self:getDrawCoordinates(true))
    self.lightSource.visible = self.anim:is("on")
end

function Lightbulb:draw()
    if self.swinging then
        love.graphics.setLineWidth(2)
        love.graphics.setLineStyle("rough")
        love.graphics.setColor(.1, .1, .1)
        local x, y = self:centerX(), self:centerY()
        love.graphics.line(x, y, x + self.offset.x, y + self.offset.y)
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setLineWidth(2)
        love.graphics.setLineStyle("rough")
        love.graphics.setColor(.1, .1, .1)
        love.graphics.line(self.start.x, self.start.y, self.start.x, self.start.y + self.ropeLength * 100)
        love.graphics.setColor(1, 1, 1)
    end

    Lightbulb.super.draw(self)
end

function Lightbulb:onSeparate(e, ...)
    Lightbulb.super.onSeparate(self, e, ...)
    self.anim:set("broken")
    self.solid = 0
    self.angle = 2

    self.scene:executeCutsceneFunction("zoomIn")

    self:delay(8, self.wrap({ visible = false }))
end

function Lightbulb:fall()
    self.swinging = false
    self.gravity = 1000
    self.velocity.y = 100
    self.anim:set("off")
    self.solid = 2
    self:set(self.x + self.offset.x, self.y + self.offset.y)
    self.offset:set(0, 0)
    self.angle = 0
    self.broken = true
end

function Lightbulb:beBroken()
    self.visible = false
    self.swinging = false
end

return Lightbulb
