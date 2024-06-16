local Enemy = require "creatures.enemy"

local Goochem = Enemy:extend("Goochem")

function Goochem:new(...)
    Goochem.super.new(self, ...)
    self:setImage("creatures/enemies/goochem", true)
    self.anim:set("idle")
    self.anim:getAnimation("to_ball"):onComplete(function() self:startRolling() end)

    self.hitbox = self:addHitbox(0, 13, 50, 45)
    self.hitboxStand = self:addHitbox(0, 0, 50, self.height)

    self.gravity = 1000
    self.origin.y = 58

    self.flip.x = false

    self.bounce:set(1, 0)
    self.maxVelocity.x = 400

    self.jumpable = true
    self.hurtsPlayer = true

    self.health = 5

    self.z = ZMAP.Peter - 3
end

function Goochem:done()
    Goochem.super.done(self)
end

function Goochem:update(dt)
    if self.dead then
        Goochem.super.update(self, dt)
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

    Goochem.super.update(self, dt)
end

function Goochem:onSeparate(e, i)
    Goochem.super.onSeparate(self, e, i)
end

function Goochem:startRolling()
    self.rotation = -20
    self.velocity.x = -400
    self.accel.x = -400
    self.hitboxStand:deactivate()
end

function Goochem:onJumpedOn()
end

function Goochem:onLaserHit()
    Goochem.super.onLaserHit(self)

    if not self.rolling then
        self.rolling = true
        self.anim:set("to_ball")
    end
end

return Goochem
