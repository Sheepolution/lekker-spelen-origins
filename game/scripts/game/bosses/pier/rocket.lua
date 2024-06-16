local SFX = require "base.sfx"
local Entity = require "base.entity"

local Rocket = Entity:extend("Rocket")

Rocket.SFX = {
    flying = SFX("sfx/bosses/pier/rocket", 1)
}

function Rocket:new(x, y, target)
    Rocket.super.new(self, x, y)
    self:setImage("bosses/pier/hat", true)
    self.target = target
    self.movementAngle = -PI / 2
    self.autoFlip.x = false

    self.rotationSpeed = 3
    self.speed = 200

    self.solid = 0
    self.z = ZMAP.IN_FRONT_OF_PLAYERS

    self:delay(2, self.F({ hurtsPlayer = true }))
end

function Rocket:update(dt)
    Rocket.super.update(self, dt)
    local angle = self:getAngleToPoint(self.target:centerX(), self.target:bottom() - 5)
    self.movementAngle = _.rotate(self.movementAngle, angle, dt * self.rotationSpeed)
    self.angle = self.movementAngle
    self:moveToAngle(self.movementAngle, self.speed)
    self.SFX.flying:play()
end

function Rocket:gotBackToPier(pier)
    self.target = pier
    self.rotationSpeed = 20
    self.speed = 600
    self.hurtsPlayer = false
    self.returning = true
end

function Rocket:destroy()
    self.SFX.flying:stop()
    Rocket.super.destroy(self)
end

return Rocket
