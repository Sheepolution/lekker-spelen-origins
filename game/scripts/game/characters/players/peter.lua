local Player = require("player", ...)

local Peter = Player:extend("Peter")

function Peter:new(...)
    Peter.super.new(self, ...)
    self:setImage("characters/players/peter", true)

    self.controllerId = 1

    self.defaultSpeed = 125
    self.runSpeed = 250
    self.crawlSpeed = self.defaultSpeed
    self.attackSpeed = self.runSpeed * 2
    self.speed = self.defaultSpeed

    self.canCrawl = true
    self.canHold = true

    self.attackTimer = step.after(.35)

    self.hitboxStand = self:addHitbox("body", 0, 4, 24, 46)
    self.hitboxCrouch = self:addHitbox("crouch", 0, 17, 24, 20)
    self.hitboxCrouch.solid = false

    self.hitboxMain = self.hitboxStand

    self.hitboxTeleportLeft = self:addHitbox("teleport_left", -21, 4, 56, 40, true)
    self.hitboxTeleportRight = self:addHitbox("teleport_right", 21, 4, 56, 40, true)

    self.hitboxes = {
        stand = self.hitboxMain,
        crouch = self.hitboxCrouch,
        run = self.hitboxCrouch,
        jump = self.hitboxCrouch,
        swim = self.hitboxCrouch,
    }

    self.jumpPower = 460
    self.jumpPowerDefault = self.jumpPower
    self.launchedPower = 610

    self.swimSpeed = { x = 175, y = 150 }

    self.abilityColor = { 213 / 255, 56 / 255, 65 / 255 }
    self.teleportEffect.color = self.abilityColor

    self.shootOffset = 5

    self.PETER = true
end

function Peter:postNew()
    Peter.super.postNew(self)
    self.indicator.x = 12
    self.indicator.y = -40
    self.indicator.anim:set("exclamation_peter")
end

function Peter:done()
    Peter.super.done(self)
    self.lightSource.offset.y = -5
end

function Peter:update(dt)
    Peter.super.update(self, dt)
end

function Peter:crouchInit()
    Peter.super.crouchInit(self)

    if self.SM:is(self.MS.Crawl)
        or self.SM:is(self.MS.Run)
        or self.SM:is(self.MS.Fall) then
        self.anim:set("crouch")
        self.anim:setFrame(3)
    end
end

function Peter:dieInit()
    self.deathGravity = 0
    self.deathVelocity = 0
    self.deathOffset = self:addOffset(0, 0)
    self:delay(.8, function()
        self.deathGravity = 1000
        self.deathVelocity = -300
    end)
end

function Peter:dieUpdate(dt)
    self.deathVelocity = self.deathVelocity + self.deathGravity * dt
    self.deathOffset.y = self.deathOffset.y + self.deathVelocity * dt
    if self.deathOffset.y > 0 then
        self.deathOffset.y = 0
        self.deathVelocity = -self.deathVelocity * .5
        if self.deathVelocity > -10 then
            self.deathVelocity = 0
            self.deathGravity = 0
        end
    end
end

function Peter:onOverlap(i)
    if i.e.tag == "Timon" then
        self:onOverlapTimon(i)
    end

    return Peter.super.onOverlap(self, i)
end

function Peter:onOverlapTimon(i)
    if i.e.SM:is(Player.MS.Crouch) and i.myBottom and i.theirHitbox.name == "crouch" then
        if i.e.teleporting or not i.e.SM:is(Player.PS.Ground) then
            return
        end

        self.velocity.y = -self.launchedPower
        self.SFX.squeak:play("reverb")
        i.e:onPeterJumpBoost()
    end
end

function Peter:handleHolding()
    if self.holdingItem then
        if self.SM:is(Player.MS.Swim) then
            self.holdingItem.z = self.z + .1
            self.holdingItem:center(self:center())
            self.holdingItem.x = self.holdingItem.x + 24 * _.boolsign(not self.flip.x)
            self.holdingItem.y = self.holdingItem.y + 18
        else
            self.holdingItem.z = self.z + .1
            self.holdingItem:center(self:center())
            self.holdingItem.x = self.holdingItem.x + 16 * _.boolsign(not self.flip.x)
            self.holdingItem.y = self.holdingItem.y + 2
        end
    end
end

function Peter:changeHitbox()
    if self.SM:is(self.MS.Run) or
        self.SM:is(self.MS.Jump) or
        self.SM:is(self.MS.Fall) then
        self:switchToHitbox("crouch")
    else
        Peter.super.changeHitbox(self)
    end
end

return Peter
