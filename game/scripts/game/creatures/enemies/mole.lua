local StateManager = require "base.statemanager"
local Enum = require "libs.enum"
local Sprite = require "base.sprite"
local Enemy = require "creatures.enemy"

local MovementStates = Enum(
    "Idle",
    "DigDown",
    "Dig",
    "DigUp",
    "Punch",
    "Fly"
)

local MS = MovementStates

local Mole = Enemy:extend("Mole")

function Mole:new(...)
    Mole.super.new(self, ...)
    self:setImage("creatures/enemies/mole", true)

    self.anim:getAnimation("dig_down")
        :onComplete(function()
            if self.justFlew then
                self.SM:to(MS.Idle)
            else
                self.SM:to(MS.Dig)
            end
        end)

    self.anim:getAnimation("punch")
        :onComplete(function() self.SM:to(MS.Idle) end)

    self.anim:getAnimation("dig_up")
        :onComplete(function()
            self.SM:to(MS.Fly)
        end)

    self:addHitbox(0, 12, 50, 44)

    self.anim:set("idle")
    self.gravity = 500
    self.offset.y = 12

    self.SM = StateManager(self, { MovementStates })
    self.SM:to(MovementStates.Idle)

    self.cooldown = step.during(.5)
    self.cooldown:finish()

    self.cooldownLooking = step.during(.5)

    self.speed = 300

    self.hurtsPlayer = false
    self.jumpable = true

    self.z = ZMAP.IN_FRONT_OF_PLAYERS
end

function Mole:done()
    Mole.super.done(self)
    self.jumper = self.type ~= "Puncher"
end

function Mole:update(dt)
    if self.died then
        Mole.super.update(self, dt)
        return
    end

    self.SM:update(dt)
    Mole.super.update(self, dt)
end

function Mole:idleInit()
    self.anim:set("idle")
    self:stopMoving()
    self.justFlew = false
    self.hurtsPlayer = false
    self.jumpable = true
end

function Mole:idleUpdate(dt)
    local nearestPlayer, distance = self:findNearestPlayer()

    if not self.cooldownLooking(dt) then
        if distance < 300 and not self.cooldown(dt) then
            self.SM:to(MS.DigDown)
        elseif distance < 380 then
            self:lookAt(nearestPlayer)
            self.anim:set("look")
        end
    end
end

function Mole:digDownInit()
    self:stopMoving()
    self.anim:set("dig_down")
    self.hurtsPlayer = false
end

function Mole:digInit()
    local nearestPlayer, distance = self:findNearestPlayer(self)
    self:lookAt(nearestPlayer)
    self:moveToDirection()

    self.anim:set("dig")

    -- self.jumpStraight = _.coin()
    self.jumpable = false
end

function Mole:digUpdate(dt)
    local nearestPlayer, distance = self:findNearestPlayer(self)

    if self.jumper then
        if self:getDistanceX(nearestPlayer) < (self.jumpStraight and 40 or 150) then
            self.SM:to(MS.DigUp)
        end
    else
        if self:getDistanceX(nearestPlayer) < 20 then
            self.SM:to(MS.Punch)
        end
    end
end

function Mole:punchInit()
    self.anim:set("punch")
    self:stopMoving()
    self.cooldown()
    self.cooldownLooking()
    self.jumpable = false
    self.hurtsPlayer = true
end

function Mole:punchUpdate(dt)
    self.jumpable = true
end

function Mole:digUpInit()
    self:stopMoving()
    self.anim:set("dig_up")
    self:createHill()
end

function Mole:flyInit()
    self:stopMoving()
    self.anim:set("fly")
    self.y = self.last.y
    self:moveUp(400)
    if not self.jumpStraight then
        self:moveToDirection(nil, 100)
    end
    self.autoAngle = true
    self.autoFlip.x = false
    self.flip.y = self.flip.x
    self.flip.x = false
    self.hurtsPlayer = true
    self.jumpable = false
end

function Mole:onSeparate(e, i)
    Mole.super.onSeparate(self, e, i)

    if self.SM:is(MS.Dig) then
        if i.myLeft or i.myRight then
            if self.jumper then
                self.SM:to(MS.DigUp)
            else
                self.SM:to(MS.Punch)
            end
        end
    end

    if self.SM:is(MS.Fly) then
        if e.tile then
            if i.myBottom then
                self.angle = 0
                self.flip.y = false
                self.autoFlip.x = true
                self.autoAngle = false
                self.justFlew = true
                self.SM:to(MS.DigDown)
                self.cooldown()
                self.cooldownLooking()
                self.hurtsPlayer = false
                self.jumpable = true
            end
        end
    end
end

function Mole:createHill()
    local hill = self.mapLevel:addEntity(Sprite(self.x, self.y + self.offset.y, "creatures/enemies/mole_hill", true),
        true)
    hill.anim:getAnimation("idle")
        :onComplete(function() hill:destroy() end)
    hill.z = self.z + 1
end

function Mole:findNearestPlayer()
    return self.scene:findNearestEntity(self, function(e) return e.playerEntity end)
end

return Mole
