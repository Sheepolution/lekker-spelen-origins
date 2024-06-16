local Banana = require "bosses.konkie.banana"
local SFX = require "base.sfx"
local Enemy = require "creatures.enemy"

local Barrel = Enemy:extend("Barrel")

Barrel.SFX = {
    breaking = {
        SFX("sfx/bosses/konkie/barrel_break1", 2, { pitchRange = .1 }),
        SFX("sfx/bosses/konkie/barrel_break2", 2, { pitchRange = .1 }),
    }
}

function Barrel:new(...)
    Barrel.super.new(self, ...)
    self:setImage("bosses/konkie/barrel", true)
    self.anim:getAnimation("explode"):onComplete(self.F:destroy())
    self.anim:set("spin")
    self.velocity.y = -1000
    self.gravity = 3200
    self.velocity.x = 360 * _.scoin()
    self.bounce.x = 1
    self:delay(0.1, function() self.anim:set("turn") end)
    self:addHitbox(80, 80)

    self.grounded = false

    self.bounceCount = 2
    self.hurtsPlayer = true

    self.health = 5
end

function Barrel:update(dt)
    Barrel.super.update(self, dt)
    if self.grounded then
        self.rotation = 5 * _.sign(self.velocity.x)
    end
end

function Barrel:extraOverlapCheck(e, myHitbox, theirHitbox)
    if not e.playerEntity then return true end
    local collide = intersect.circle_aabb_overlap(vec2(self:center()), 42,
        vec2(theirHitbox.bb.x, theirHitbox.bb.y),
        vec2(theirHitbox.bb.width, theirHitbox.bb.height))

    return collide
end

function Barrel:onSeparate(e, i)
    Barrel.super.onSeparate(self, e, i)
    if i.myBottom then
        if not self.grounded then
            self.grounded = true
            if _.coin() then
                self.velocity.y = -1000
                self.bounce.y = 1
            end
        end
    elseif i.myLeft or i.myRight then
        self.bounceCount = self.bounceCount - 1
        if self.bounceCount == 0 then
            self.gravity = 0
            self.accel:set(0)
            self.anim:set("explode")
            _.pick(self.SFX.breaking):play("reverb")
            local x, y = self:center()
            self.mapLevel:add(Banana(x, y, i.myRight))
            self:stopMoving()
        end
    end
end

return Barrel
