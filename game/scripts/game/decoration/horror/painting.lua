local Player = require "characters.players.player"
local Entity = require "base.entity"

local Painting = Entity:extend("Appie")

function Painting:new(...)
    Painting.super.new(self, ...)
    self.z = ZMAP.TOP
    self.origin.y = 5
    self.pendulum = false
end

function Painting:done()
    if self.name then
        self:setImage("decoration/horror/painting_" .. self.name)
    end
    self:clearHitboxes()
    self:addHitbox("solid", self.width * .5, self.height * .5)
    self.origin.y = 5
end

function Painting:update(dt)
    if self.pendulum then
        local angle = self.angle
        self.angle = self.angle + self.pendulumVelocity * dt
        self.pendulumVelocity = self.pendulumVelocity + 4 * dt * self.pendulumDirection

        if _.sign(angle) ~= _.sign(self.angle) then
            if self.angle > 0 then
                self.pendulumDirection = -1
                self.pendulumVelocity = self.pendulumVelocity * .70
            else
                self.pendulumDirection = 1
                self.pendulumVelocity = self.pendulumVelocity * .70
            end

            if math.abs(self.pendulumVelocity) < .3 then
                self.pendulum = false
                self.angle = 0
            end
        end
    end

    Painting.super.update(self, dt)
end

function Painting:onOverlap(i)
    if i.e:is(Player) then
        if not self.pendulum then
            self.pendulum = true
            self.pendulumDirection = 1
            self.pendulumVelocity = -2
        end
    end
end

return Painting
