local SFX = require "base.sfx"
local Entity = require "base.entity"

local Enemy = Entity:extend("Enemy")

Enemy.SFX = {
    hit = SFX("sfx/enemies/hit", 3),
    shot = SFX("sfx/enemies/shot", 4, { pitchRange = .1 }),
}

Enemy:addIgnoreOverlap(Enemy)

function Enemy:new(...)
    Enemy.super.new(self, ...)
    self.health = 5
    self.blinkTimer = step.once(.05)
    self.blinkWhiteDelay = step.during(.1)
end

function Enemy:update(dt)
    Enemy.super.update(self, dt)

    if self.singleColor then
        if self.blinkTimer(dt) then
            self.singleColor = nil
        end
    end

    self.blinkWhiteDelay(dt)
end

function Enemy:onJumpedOn()
    self:kill()
end

function Enemy:onHit()
    if self.hitEvent then
        self.hitEvent:stop()
    end
    self.hitEvent = self:event(
        function()
            self.visible = not self.visible
        end, .11, 14,
        function()
            self.hitEvent = nil
            self.visible = true
        end)
end

function Enemy:kill()
    if self.died then return end
    self.died = true
    self:stopMoving()
    local s = _.scoin()
    self.velocity.x = 100 * s
    self.rotation = 2 * s
    self.velocity.y = -300
    self.gravity = 2500
    self.autoFlip.x = false
    self:delay(2, self.F:destroy())
    self.solid = 0
    self.hurtsPlayer = false
    self.jumpable = false

    Enemy.SFX.hit:play()

    if self.anim:has("dead") then
        self.anim:set("dead")
    end
end

function Enemy:onLaserHit()
    if not self.health then return end

    self.health = self.health - 1

    Enemy.SFX.shot:play("reverb")

    if self.health <= 0 then
        self:kill()
    else
        self:blinkWhite()
    end
end

function Enemy:blinkWhite()
    if not self.blinkWhiteDelay(0) then
        self.singleColor = { 255, 255, 255 }
        self.blinkTimer()
        self.blinkWhiteDelay()
    end
end

return Enemy
