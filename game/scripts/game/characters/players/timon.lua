local Player = require("player", ...)

local Timon = Player:extend("Timon")

Timon.SFX.hurt = "players/hurt_timon"

function Timon:new(...)
    Timon.super.new(self, ...)
    self:setImage("characters/players/timon", true)

    self.controllerId = 2

    self.defaultSpeed = 140
    self.runSpeed = 230
    self.speed = self.defaultSpeed
    self.pushSpeed = self.defaultSpeed * 0.5

    self.canCrawl = false
    self.canPush = true
    self.canSniff = true

    self.hitboxStand = self:addHitbox("body", 0, 20, 55, 42)
    self.hitboxCrouch = self:addHitbox("crouch", 0, 30, 55, 22)
    self.hitboxCrouch.solid = false
    self.hitboxSwim = self:addHitbox("swim", 0, 14, 60, 22)
    self.hitboxSwim.active = false

    self.hitboxMain = self.hitboxStand

    self.hitboxTeleportLeft = self:addHitbox("teleport_left", 0, 14, 5, 5, true)
    self.hitboxTeleportRight = self:addHitbox("teleport_right", 0, 14, 5, 5, true)

    self.hitboxBlockPush = self:addHitbox("block_push", 0, 0, 78, 25)

    self.hitboxes = {
        stand = self.hitboxMain,
        crouch = self.hitboxCrouch,
        run = self.hitboxStand,
        jump = self.hitboxStand,
        swim = self.hitboxSwim
    }

    self.isTimon = true

    self.jumpPower = 520
    self.jumpPowerDefault = self.jumpPower

    self.sniffRadius = 0
    self.sniffRadiusMax = 500
    self.sniffOffset = {
        x = 43,
        y = 18
    }

    self.swimSpeed = { x = 150, y = 175 }

    self.abilityColor = { 64 / 255, 130 / 255, 229 / 255 }
    self.teleportEffect.color = self.abilityColor

    self.separatePriority:set(100, 100)

    self.shootOffset = 28
end

function Timon:postNew()
    Timon.super.postNew(self)
    self.indicator.x = 30
    self.indicator.y = -44
    self.indicator.anim:set("exclamation_timon")
end

function Timon:done()
    Timon.super.done(self)
    self.lightSource.offset.y = 10
end

function Timon:onPeterJumpBoost()
    self.inputHoldingDown = false
    self.SM:to(Player.MS.Standup, true)
    self.SFX.bark:play("reverb")
end

return Timon
