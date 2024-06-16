local Enemy = require "creatures.enemy"
local Entity = require "base.entity"

local Laser = Entity:extend("Laser")

function Laser:new(x, y, direction, tag, angle)
    Laser.super.new(self)
    self:setImage("projectiles/laser", true)

    tag = tag:lower()
    self.anim:set("grow_" .. tag)
    self.anim:getAnimation("dead_" .. tag)
        :onComplete(function()
            self:destroy()
        end)

    self:center(x, y)

    self.speed = 1500

    self.autoFlip.x = false

    self.angle = _.directionToAngle(direction)
    self.angle = self.angle + (angle or 0)
    self:moveToAngle(self.angle, self.speed)

    self:setStart()

    self.maxDistance = 350
    self.playerTag = tag
    self.solid = 0

    self:addHitbox(0, 0, self.height, self.height)
end

function Laser:update(dt)
    if self:getDistance(self.start) > self.maxDistance then
        self:kill(true)
    end

    Laser.super.update(self, dt)
end

function Laser:onOverlap(i)
    if i.e.solid == 2 and i.theirHitbox.solid then
        self:kill()
    end

    if i.e:is(Enemy) then
        if not self.died then
            i.e:onLaserHit()
            self:kill()
        end
    end

    return false
end

function Laser:kill(fake)
    if self.died then return end
    if self.diedFake then return end
    if fake then
        self.diedFake = true
        self:cb(function()
            self:cb(function()
                self.died = true
            end)
        end)
    else
        self.died = true
    end

    self:stopMoving()
    self.solid = 0
    local distance = self:getDistance(self.start)
    self:positionToAngle(self.start.x, self.start.y, self.angle, distance + 30)
    self.anim:set("dead_" .. self.playerTag)
    self.angle = _.randomAngle()
end

return Laser
