local SFX = require "base.sfx"
local Enemy = require "creatures.enemy"

local Hellhound = Enemy:extend()

Hellhound.SFX = {
    bark = {
        SFX("sfx/bosses/hellhound/bark1"),
        SFX("sfx/bosses/hellhound/bark2"),
        SFX("sfx/bosses/hellhound/bark3"),
    }
}

function Hellhound:new(...)
    Hellhound.super.new(self, ...)
    self:setImage("bosses/hellhound/hellhound", true)
    self.gravity = 2000
    self.jumping = false
    self.anim:getAnimation("bark"):after("idle", 2)
    self.anim:set("idle")
    self.tiredDelay = step.once(3)
    self.jumpDelay = step.once(.5, 2)
    self:addHitbox(10, 45, self.width * .6, 40)

    self.jumpsBeforeTiredMax = 4
    self.jumpsBeforeTired = 4

    self.hurtsPlayer = true
    self.health = 4

    self.z = ZMAP.Hellhound

    self.currentBark = 1
    self.currentBarkRandom = _.unique_weighted(1, 3)
end

function Hellhound:update(dt)
    if not self.active then return end

    if not self.fighting then
        Hellhound.super.update(self, dt)
        return
    end

    if self.jumping then
        if self.velocity.y > 0 then
            self.anim:set("fall")
        end
    end

    if self.diedFake then
        local players = self.scene:getPlayers()
        if players[1].x > self.mapLevel.x + self.mapLevel.width - 250 and
            players[2].x > self.mapLevel.x + self.mapLevel.width - 250 then
            self.diedFake = false
            self.hurtsPlayer = true
            self.jumpDelay:finish(true)
            self:delay(1, function()
                self:jump(true)
            end)
        end
    end

    if self.tired and not self.died and not self.diedFake then
        if self.tiredDelay(dt) then
            self.tired = false
            self.anim:set("idle")
            self.jumpable = false
            self.jumpDelay()
        end
    end

    if not self.jumping then
        if self.jumpDelay(dt) then
            self:jump()
        end
    end

    Hellhound.super.update(self, dt)
end

function Hellhound:jump(surprise)
    self.hurtsPlayer = true
    local player = _.pick(self.scene:getPlayers())
    local distance = self:getDistance(player)

    local factor = distance / 721

    self.velocity.y = -800
    self.jumping = true
    self.anim:set("jump")
    self.hitPlayer = false

    self:lookAt(player)

    if surprise then
        self:moveForwardHorizontally(840 * factor)
    else
        local look = player:isLookingAt(self) and -1 or 1.25
        self:moveForwardHorizontally(math.max(100, 840 * factor + (_.coin() and 0 or (150 * look))))
    end
end

function Hellhound:onLand()
    if self.health == 1 and not self.scene.music:isPlaying() then
        self.scene.music:play("bosses/hellhound/theme2", nil, true)
    end

    if self.health == 2 and self.jumpsBeforeTired == 1 then
        if self:centerX() < self.mapLevel.x + self.mapLevel.width / 2 then
            self.jumpsBeforeTired = 0
        end
    else
        if not self.hitPlayer then
            self.jumpsBeforeTired = self.jumpsBeforeTired - 1
        end
    end

    self.velocity.x = 0
    self.jumping = false
    local player = self.scene:findNearestPlayer(self)

    if self.jumpsBeforeTired <= 0 and not self.hitPlayer then
        self.anim:set("tired")
        self.tired = true
        self.tiredDelay()
        self.jumpsBeforeTired = self.jumpsBeforeTiredMax
        self.jumpable = true
        self.hurtsPlayer = false
        return
    end

    self:lookAt(player)
    self.anim:set("bark")
    self.jumpDelay()
    self.SFX.bark[self.currentBark]:play()
    self.currentBark = self.currentBarkRandom()

    self.hitPlayer = false
end

function Hellhound:onOverlap(i)
    if i.e.playerEntity and i.theirHitbox == i.e.hitboxMain and self.hurtsPlayer then
        self.hitPlayer = true
    end

    return Hellhound.super.onOverlap(self, i)
end

function Hellhound:onSeparate(e, i)
    if i.myBottom and self.jumping and self.velocity.y < 0 then
        return
    end

    Hellhound.super.onSeparate(self, e, i)
    if self.jumping then
        if i.myBottom and self.velocity.y == 0 then
            self:onLand()
        end
    end
end

function Hellhound:onHit()
    Hellhound.super.onHit(self)
    Enemy.SFX.hit:play()
    self.tired = false
    self.anim:set("idle")
    self.jumpable = false
    self.jumpDelay()
    self.tiredDelay:finish(true)
end

function Hellhound:onJumpedOn()
    self.health = self.health - 1
    self.jumpsBeforeTiredMax = self.jumpsBeforeTiredMax + 1
    self.jumpsBeforeTired = self.jumpsBeforeTiredMax

    if self.health > 1 then
        self:onHit()
        return
    elseif self.health == 1 then
        Enemy.SFX.hit:play()
        self.diedFake = true
        self.anim:set("dead")
        self.jumpable = false
        self.hurtsPlayer = false
        self.scene.music:pause(.5)
    else
        Enemy.SFX.hit:play()
        self.died = true
        self.anim:set("dead")
        self.jumpable = false
        self.hurtsPlayer = false
        self.room:onDefeat()
        self.scene.music:stop(.5)
    end
end

return Hellhound
