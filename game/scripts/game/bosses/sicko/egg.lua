local SFX = require "base.sfx"
local Entity = require "base.entity"

local Egg = Entity:extend("Egg")

Egg.SFX = {
    bounce = SFX("sfx/bosses/sicko/egg_bounce", 2, { pitchRange = .1 }),
    breaking = SFX("sfx/bosses/sicko/egg_break", 2, { pitchRange = .1 }),
}

function Egg:new(x, y, dir)
    Egg.super.new(self, x, y)
    self:setImage("bosses/sicko/projectiles/egg", true)
    self.anim:set("idle")
    self.bounce:set(1, 1)
    self.velocity.x    = _.signbool(dir) and -700 or 400
    self.velocity.y    = -_.random(100, 350)

    self.rotation      = _.random(1, 3) * _.scoin()
    self.gravity       = 1600

    self.hitbox        = self:addHitbox(self.height * .8, self.height * .8)

    self.bounceCounter = 7

    self:center(x, y)

    self.hurtsPlayer = true
end

function Egg:update(dt)
    Egg.super.update(self, dt)
end

function Egg:onSeparate(e, i)
    Egg.super.onSeparate(self, e, i)
    if e.tile then
        if i.myBottom then
            self.bounceCounter = self.bounceCounter - 1
            if self.bounceCounter < 0 then
                self:onBreak()
            else
                self.SFX.bounce:play("reverb")
            end
        end
    end
end

function Egg:onBreak()
    if self.broken then
        return
    end

    self.SFX.breaking:play("reverb")
    self:stopMoving()
    self.hurtsPlayer = false
    self.offset.y = 6
    self.anim:set("broken")
    self.broken = true
    self.angle = 0
    self.rotation = 0
    self.hurtsPlayer = false
    self.bounce:set(0, 0)
    self:tween(1, { alpha = 0 }):oncomplete(function()
        self:destroy()
    end):delay(5)
    self.z = ZMAP.IN_FRONT_OF_PLAYERS
end

return Egg
