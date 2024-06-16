local Particle = require "base.particle"

local Particles = {}

function Particles.sickoSmoke(x, y, flip)
    local self = Particle(x, y)

    self:setImage("particles/sicko/smoke")

    self.velocity.x = 10 * -_.boolsign(flip)
    self.velocity.y = -20

    self.alphaSpeed = -.3

    return self
end

function Particles.bubble(x, y, rand)
    local self = Particle(x, y)

    if rand then
        self:positionToAngle(self.x, self.y, _.randomAngle(), _.random(0, rand))
    end

    self:setImage("particles/bubble")

    self.velocity.y = -_.random(15, 25)

    self.alphaSpeed = -_.random(.1, .5)

    return self
end

return Particles
