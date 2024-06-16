local Enemy = require "creatures.enemy"

local Smeef = Enemy:extend("Smeef")

function Smeef:new(...)
    Smeef.super.new(self, ...)
    self:setImage("creatures/enemies/smeef", true)
    self.anim:set("idle")
    self.anim:getAnimation("to_ball"):onComplete(function() self:startRolling() end)

    self.hitbox = self:addHitbox(0, 13, 50, 45)

    self.gravity = 1000
    self.origin.y = 49

    self.flip.x = false

    self.bounce:set(1, 0)
    self.maxVelocity.x = 400

    self.jumpable = true
    self.hurtsPlayer = true

    self.health = 5
    self.z = ZMAP.IN_FRONT_OF_PLAYERS
end

function Smeef:done()
    Smeef.super.done(self)
end

function Smeef:update(dt)
    if self.dead then
        Smeef.super.update(self, dt)
        return
    end

    local nearest_payer, distance = self.scene:findNearestPlayer(self)

    if not self.rolling then
        if distance < 300 then
            self.rolling = true
            self.anim:set("to_ball")
        elseif distance < 400 then
            self:lookAt(nearest_payer)
        end
    else
        if self.anim:is("ball") then
            if self:centerX() < nearest_payer:centerX() then
                self.accel.x = 1000
            else
                self.accel.x = -1000
            end

            self.rotation = 20 * _.sign(self.accel.x)
        end
    end

    Smeef.super.update(self, dt)
end

function Smeef:onSeparate(e, i)
    Smeef.super.onSeparate(self, e, i)
end

function Smeef:startRolling()
    self.rotation = -20
    self.velocity.x = -400
    self.accel.x = -400
end

return Smeef
