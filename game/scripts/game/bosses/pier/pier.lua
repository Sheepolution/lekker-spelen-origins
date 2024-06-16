local StateManager = require "base.statemanager"
local Enum = require "libs.enum"
local Rocket = require("rocket", ...)
local Sprite = require "base.sprite"
local AccessPass = require "pickupables.accesspass"
local SFX = require "base.sfx"
local Enemy = require "creatures.enemy"

local Pier = Enemy:extend("PierBoss")

local MS = Enum(
    "Idle",
    "Drill",
    "Wheel",
    "Rocket",
    "Hurt",
    "Dead"
)

Pier.MS = MS

Pier.SFX = {
    drill = SFX("sfx/bosses/pier/drill", 1, { pitchRange = .1 }),
    bounce = SFX("sfx/bosses/pier/slime", 2, { pitchRange = .15 }),
    hit = SFX("sfx/bosses/pier/hit", 1),
    laugh = { SFX("sfx/bosses/pier/laugh", 1), SFX("sfx/bosses/pier/yeah", 1) }
}

function Pier:new(...)
    Pier.super.new(self, ...)
    self:setImage("bosses/pier/pier", true)
    self.anim:set("idle")
    self.anim:getAnimation("drill_in_ground")
        :onComplete(function()
            if self.drillCounter() then
                self:toRocket()
            else
                self:goToRandomCeilingPosition()
            end
        end)
        :after("drill")

    self.anim:getAnimation("in_rocket")
        :onComplete(function()
            self.jumpable = false
        end)

    self.flip.x = true
    self.offset.y = 2

    self.SM = StateManager(self, { Pier.MS })
    self.SM:to(Pier.MS.Idle)
    self.start = {
        x = self.x,
        y = self.y
    }

    self.stopWheelDelay = step.after(.2)

    self.holes = list()

    self.holePositions = {}

    self.rocketOutTimer = step.once(1)
    self.rocketInTimer = step.once(1)

    self.underground = false
    self.hurtsPlayer = false

    self.wheelJumpPower = 1100
    self.drillCounter = count.new(7)
    self.bounceCounter = count.new(15)
    self.rocketCounter = count.new(5)

    self.health = 3

    self:addHitbox(0, 18, 27, 31)
end

function Pier:done()
    Pier.super.done(self)
end

function Pier:update(dt)
    if self.SM:is(MS.Wheel) then
        if self.velocity.x > 1000 then
            if self.stopWheelDelay(dt) then
                self:toDrill()
            end
        end
    end

    if self.SM:is(MS.Rocket) then
        if self.underground then
            if self.rocketOutTimer(dt) then
                local holePosition = _.pick(self.holePositions)
                self.x = holePosition.x
                self.y = holePosition.y
                self.anim:set("out_rocket")
                self.underground = false
                self.jumpable = true
                self.rocketInTimer()

                if self.rocketCounter() then
                    self.SM:to(MS.Idle)
                    self:endRocket()
                    self.endRocketTimer = self:delay(1.5, function()
                        self:toWheel()
                    end)
                end
            end
        else
            if self.rocketInTimer(dt) then
                self.anim:set("in_rocket")
                self.underground = true
                self.rocketOutTimer()
            end
        end
    end

    Pier.super.update(self, dt)
end

function Pier:startBossFight()
    self:createHole(1, 0)
    self:delay(4, function()
        self:toWheel()
    end)
end

function Pier:onOverlap(i)
    if i.e.tile then
        if self.SM:is(MS.Drill) then
            self.SFX.drill:play()
            self.anim:set("drill_in_ground")
        end
    end

    if i.e.tag == "Rocket" then
        if i.e.returning then
            i.e:destroy()

            if self.anim:is("hit") then
                self.anim:set("hit_hat")
            elseif self.anim:is("out_rocket") or self.anim:is("rocket") then
                self.anim:set("idle")
                self.jumpable = false
            end
        end
    end
end

function Pier:onSeparate(e, i)
    Pier.super.onSeparate(self, e, i)

    if e.tile then
        if self.SM:is(MS.Wheel) then
            if i.myBottom then
                self.velocity.y = -self.wheelJumpPower
                self.SFX.bounce:play()
                if self.bounceCounter() then
                    self.y = self.y - 1
                    self:createHole()
                    self:toDrill()
                end
            end
        end
    end

    if self.anim:is("drill_in_ground") then
        self:createHole(0, -1)
    end
end

function Pier:createHole(offsetX, offsetY)
    local hole = self.holes:add(self.mapLevel:add(Sprite(0, 0, "bosses/pier/hole", true)))
    hole:center(self:centerX() + (offsetX or 0), self:bottom() - 1 + (offsetY or 0))
    hole.z = self.z + 1

    table.insert(self.holePositions, {
        x = self.x,
        y = self.y
    })
end

function Pier:toRocket()
    self.hurtsPlayer = false
    self.jumpable = false
    self:stopMoving()
    self.y = self.start.y
    self.gravity = 0
    self.bounce:set(0, 0)
    self.anim:set("out")
    self.rocketCounter(true)
    self.rocketInTimer()
    self.rocketOutTimer()

    self:delay(.8, function()
        self.SM:to(MS.Rocket)
        self.anim:set("rocket")
        self.underground = false
        self.rocket = self.mapLevel:add(Rocket(self.x, self.y, _.pick(self.scene:getPlayers())))
    end)
end

function Pier:toWheel()
    self.jumpable = false
    self:stopMoving()
    self.y = self.start.y
    self.gravity = 0
    self.bounce:set(0, 0)
    self.bounceCounter(true)
    self:delay(.3, function()
        self:delay(2, function()
            self:laugh()
            self.hurtsPlayer = true
        end)

        self.SM:to(MS.Wheel)
        self.anim:set("wheel")
        self.velocity:set(0, -self.wheelJumpPower)
        self.accel.x = 200 * _.scoin()
        self.maxVelocity:set(550, self.wheelJumpPower)
        self.gravity = 4800
        self.bounce:set(1.01, 1.01)
        self.bounceAccel:set(1, 0)
    end)
end

function Pier:toDrill()
    self:stopMoving()

    self.y = self.start.y
    self.gravity = 0
    self.bounce:set(0, 0)

    self.anim:set("in")
    self.hurtsPlayer = false

    self:delay(3, self.F:laugh())

    self:delay(1, function()
        self.hurtsPlayer = true
        self.flip.x = false
        self.SM:to(MS.Drill)
        self.anim:set("drill")
        self:goToRandomCeilingPosition()
    end)
end

function Pier:goToRandomCeilingPosition()
    local player = _.pick(self.scene:getPlayers())
    self.x = player:centerX() + _.random(-50, 80, true) * _.boolsign(not player.flip.x)
    self.x = _.clamp(self.x, self.mapLevel.x + 50, self.mapLevel.x + self.mapLevel.width - 232)
    self.y = self.mapLevel.y + 10
    self:teleport()
    self:moveDown(620)
end

function Pier:onJumpedOn()
    self:onHit()
end

function Pier:onHit()
    self.SFX.hit:play()
    self.y = self.start.y
    self.health = self.health - 1
    if self.health <= 0 then
        self:die()
    end

    if self.endRocketTimer then
        self.endRocketTimer:stop()
        self.endRocketTimer = nil
    end

    if self.died then
        return
    end

    self.jumpable = false
    self.SM:to(MS.Hurt)
    self.anim:set("hit")
    self:event(
        function()
            self.visible = not self.visible
        end, .11, 14,
        function()
            self.visible = true
        end)

    self:endRocket()

    self:delay(1.5, function()
        self:toWheel()
    end)
end

function Pier:endRocket()
    self.rocket:gotBackToPier(self)

    self:delay(1.5, function()
        if not self.rocket.destroyed then
            self.rocket:destroy()
        end
    end)
end

function Pier:die()
    self.SM:to(MS.Dead)
    self.died = true
    self.jumpable = false
    self.hurtsPlayer = false
    self.anim:set("dead")
    if self.rocket then
        self.rocket:destroy()
    end

    local ap = AccessPass(self:centerX(), self:centerY())
    ap.pickupable = false
    ap.access = 6
    ap.gravity = 1000
    ap.velocity.y = -300
    ap.velocity.x = 90
    ap.exclusiveOverlap = false
    ap.exclusiveOverlapCache = false

    ap.onOverlap = function(s, i)
        AccessPass.onOverlap(s, i)

        if i.e.tile then
            s:stopMoving()
            s.accel.y = 0
            s.gravity = 0
        end
    end

    self.mapLevel:add(ap)

    self.room:onPierDefeated()
end

function Pier:laugh()
    _.pick(self.SFX.laugh):play()
end

return Pier
