local Enemy = require "creatures.enemy"

local Banana = Enemy:extend("Banana")

function Banana:new(x, y, left)
    Banana.super.new(self, x, y)
    self:setImage("bosses/konkie/banana", true)
    self.anim:set("flying")
    self.gravity = 1500

    self.autoFlip.x = false

    if left then
        self.angle = -math.pi * .65
        self.x = self.x - 20
    else
        self.angle = -math.pi * .35
        self.x = self.x + 20
    end

    self.autoAngle = true

    self.hurtsPlayer = true

    self.health = 3

    self:moveToAngle(self.angle, _.random(600, 800))
    self.z = ZMAP.IN_FRONT_OF_PLAYERS
    self:addHitbox(0, 0, self.width * .8, self.height * .8)
end

function Banana:update(dt)
    Banana.super.update(self, dt)
end

function Banana:onSeparate(e, i)
    Banana.super.onSeparate(self, e, i)
    if i.myBottom then
        self.anim:set("idle")
        self:stopMoving()
        self.angle = 0
        self.autoAngle = false
    end
end

return Banana
