local SFX = require "base.sfx"
local Entity = require "base.entity"

local Centaur = Entity:extend("Centaur")

Centaur.SFX = {
    sound = SFX("sfx/bosses/centaur/centaursound")
}

function Centaur:new(...)
    Centaur.super.new(self, ...)
    self:setImage("bosses/centaur/centaur", true)
    self.anim:set("black")
    self.z = ZMAP.Centaur
    self.solid = 0

    self:addHitbox("solid", -120 - self.width, 0, self.width * 3, self.height)

    self.soundInterval = step.every(5, 10)
end

function Centaur:update(dt)
    Centaur.super.update(self, dt)
    if self.running and not self.dead then
        if self.soundInterval(dt) then
            self:sound()
        end
    end
end

function Centaur:sound()
    Centaur.SFX.sound:play("reverb")
end

function Centaur:startRunning()
    self:moveRight(270)
    self.anim:set("run")
    self.hurtsPlayer = true
    self.running = true
end

function Centaur:onOverlap(i)
    if not self.dead then
        if i.e.tag == "Block" then
            if self.x > self.mapLevel.x + self.mapLevel.width * .8 and i.e.velocity.y > 100 then
                self.anim:set("dead")
                self:stopMoving()
                self:addMovement(270, 0, 250, nil, true, "x")
                self.dead = true
                self.running = false
                self.room:onDefeatingCentaur()
            end
        end
    end
end

return Centaur
