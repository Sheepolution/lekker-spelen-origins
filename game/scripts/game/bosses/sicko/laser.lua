local Entity = require "base.entity"

local Laser = Entity:extend("Laser")

function Laser:new(x, y, direction, low)
    Laser.super.new(self, x, y)
    self:setImage("bosses/sicko/projectiles/laser", true)

    self.origin:set(0, 0)

    self.solid = 0
    self.hitbox = self:addHitbox("solid", 0, low and 8 or 0, self.width, self.height, nil, false)
    self.direction = direction

    self.increaseTimer = step.during(low and .2 or 1.2)
    self.hurtsPlayer = true
    self.scale.y = 1.4
    self:setFilter("nearest", "linear")
    self.z = ZMAP.IN_FRONT_OF_PLAYERS
end

function Laser:update(dt)
    Laser.super.update(self, dt)

    if self.increaseTimer(dt) then
        self:increase(dt)
    else
        self.velocity.x = 1250 * self.direction
    end

    if self.x > self.mapLevel.x + self.mapLevel.width then
        self:destroy()
    end
end

function Laser:increase(dt)
    self.scale.x = self.scale.x + 1250 * dt
    self.hitbox.width = self.width * self.scale.x
    self.hitbox.height = 5
    self.hitbox:setBoundingBox()
    self.hitbox.changed = true
    self.moved = true
end

return Laser
