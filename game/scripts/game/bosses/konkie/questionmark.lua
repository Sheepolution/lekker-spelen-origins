local SFX = require "base.sfx"
local Enemy = require "creatures.enemy"

local QuestionMark = Enemy:extend("QuestionMark")

QuestionMark.SFX = {
    dead = {
        SFX("sfx/bosses/konkie/qm_dead1", nil, { pitchRange = .1 }),
        SFX("sfx/bosses/konkie/qm_dead2", nil, { pitchRange = .1 }),
    }
}

function QuestionMark:new(x, y, low)
    QuestionMark.super.new(self, x, y)
    self:setImage("bosses/konkie/question_mark", true)
    self.anim:set("grow")
    self.anim:getAnimation("dead"):onComplete(self.F:destroy())

    self.rgb = {
        r = 114,
        g = 1,
        b = 255
    }

    self:setColor(114, 1, 255)

    if low then
        self:delay(1, function()
            self["to" .. _.pick({ "ExclamationPoint", "I" })](self)
        end)
    else
        self:delay(1, function()
            self["to" .. _.pick({ "ExclamationPoint", "Circle", "I" })](self)
        end)
    end

    self.angleOffset = -PI / 2
    self.angle = PI / 2

    self.health = 3

    self:addHitbox()
    self.hurtsPlayer = true
end

function QuestionMark:update(dt)
    if self.targetedPlayer then
        self:rotateTowards(self.targetedPlayer, 2 * dt)
    end

    QuestionMark.super.update(self, dt)
end

function QuestionMark:toExclamationPoint()
    self.state = "!"
    self.anim:set("to_!")
    self:tween(self.rgb, .5, {
        r = 255,
        g = 100,
        b = 100
    }):onupdate(function()
        self:setColor(self.rgb.r, self.rgb.g, self.rgb.b)
    end)

    self:tween(self.origin, .5, { y = self.height - 8 })

    self:delay(1, function()
        self:targetPlayer()
    end)

    self.solid = 0
    self.damageBox = self:addHitbox("damage", 0, self.height / 2 - 15, 5, 5)
end

function QuestionMark:toCircle()
    self.state = "o"
    self.anim:set("to_o")
    self:tween(self.rgb, .5, {
        r = 100,
        g = 255,
        b = 100
    }):onupdate(function()
        self:setColor(self.rgb.r, self.rgb.g, self.rgb.b)
    end)

    self.useGravity = true
    self.gravity = 800
    self.velocity.x = _.random(250, 300) * _.scoin()
    self.bounce.x = 1
    self.bounce.y = 0.9

    self.damageBox = self:addHitbox("damage", 0, 27, self.width * .8, self.width * .8)
end

function QuestionMark:toI()
    self.state = "i"
    self.flip.x = true
    self.anim:set("i")
    self:tween(self.rgb, .5, {
        r = 100,
        g = 100,
        b = 255
    }):onupdate(function()
        self:setColor(self.rgb.r, self.rgb.g, self.rgb.b)
    end)

    self.useGravity = true
    self.gravity = 400

    self.damageBox = self:addHitbox("damage", 0, 21, self.width * .75, self.width)
end

function QuestionMark:startWalking()
    if self:isMoving("x") then
        return
    end

    self.velocity.x = 200 * _.scoin()
    self.bounce.x = 1
end

function QuestionMark:targetPlayer()
    self.targetedPlayer = self.scene:findNearestPlayer(self)
    self.angularVelocity = 200
end

function QuestionMark:onSeparate(e, i)
    if e.tile then
        if self.state == "i" then
            self:startWalking()
        end
    end

    QuestionMark.super.onSeparate(self, e, i)
end

function QuestionMark:kill()
    QuestionMark.super.kill(self)
    _.pick(QuestionMark.SFX.dead):play("reverb")
end

return QuestionMark
