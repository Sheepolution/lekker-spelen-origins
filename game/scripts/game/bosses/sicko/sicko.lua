local Enum = require "libs.enum"
local StateManager = require "base.statemanager"
local Egg = require("egg", ...)
local Laser = require("laser", ...)
local BeerSpill = require("beer_spill", ...)
local Sprite = require "base.sprite"
local Enemy = require "creatures.enemy"
local Blueprint = require "pickupables.blueprint"
local SFX = require "base.sfx"
local Smoke = require("smoke", ...)

local Sicko = Enemy:extend("Sicko")

local MS = Enum(
    "Idle",
    "Beer",
    "Laser",
    "Eggs",
    "Smoke",
    "Skateboard",
    "Dead"
)

Sicko.MS = MS

Sicko.SFX = {
    laser = SFX("sfx/bosses/sicko/laser", 1, { pitchRange = .1 }),
    laser_long = SFX("sfx/bosses/sicko/laser_long", 1, { pitchRange = .1 }),
    skateboard_jump = SFX("sfx/bosses/sicko/skateboard_jump"),
    skateboard_land = SFX("sfx/bosses/sicko/skateboard_land"),
    guitar = { SFX("sfx/bosses/sicko/guitar1"), SFX("sfx/bosses/sicko/guitar2") }
}

function Sicko:new(x, y, first)
    Sicko.super.new(self, x, y)
    self:setImage("bosses/sicko/sicko", true)
    self.anim:getAnimation("laser_high")
        :onComplete(self.F:shootLasersHigh(), true)

    self.anim:getAnimation("laser_low")
        :onComplete(self.F:shootLasersLow(), true)

    self.anim:getAnimation("skateboard_trick")
        :onFrame(3, function()
            local sickoText = self.mapLevel:add(Sprite(0, 0, "bosses/sicko/sicko_to_the_bone", true))
            sickoText:center(self:getRelativePosition(80, -80))
            sickoText.z = ZMAP.BEHIND_PLAYERS
            sickoText.anim:set("appear")
            sickoText:tween(.5, { alpha = 0 })
                :oncomplete(sickoText.F:destroy())
                :delay(4)
            self.sickoText = sickoText
        end)

    self.anim:set("fly_idle")
    self:center(x, y)
    self:setStart()

    self.hitbox = self:addHitbox(0, 12, 60, self.height - 24)

    self.beerTimerFly = step.every(.35, 1)
    self.beerTimerSpill = step.every(.8)

    self.smokeTimer = step.every(.6)

    self.beerCounter = count.new(10, true)
    self.laserCounter = count.new(12, true)
    self.smokeCounter = count.new(19, true)
    self.skateboardCounter = count.new(4, 7, true)

    self.lowLaserChance = 99
    self.highLaserChance = 20

    self.updateSpeed = 1

    self.SM = StateManager(self, { MS })
    self.SM:to(MS.Idle)
    self.spillBeer = false
    self.bounce:set(1, 0)

    self.currentAttack = 0
    self.allAttacks = list({ self.startSmoke, self.shootEggs, self.prepareForLaser, self.startBeer })

    if first then
        self.attacks = list({ self.prepareForLaser, self.startBeer, self.shootEggs })
        self.attackNotUsedLastRound = self.startSmoke
    else
        self:getThreeRandomAttacks(true)
    end

    self.hurtsPlayer = true

    self.health = 3

    self.z = -1
end

function Sicko:update(dt)
    dt = dt * self.updateSpeed
    self.SM:update(dt)

    Sicko.super.update(self, dt)
end

function Sicko:onSeparate(e, i)
    Sicko.super.onSeparate(self, e, i)
    if self.SM:is(MS.Skateboard) then
        if i.myLeft or i.myRight then
            if not self.skateboardJumping then
                self:onSkateboardBounce()
            end
        elseif i.myBottom then
            if self.skateboardJumping then
                self:onSkateboardLand()
            end
        end
    end
end

function Sicko:toIdleState()
    self.SM:to(MS.Idle)
    self:stopMoving()
    self.anim:set("fly_idle")
    self.offset.y = 0

    self:tween(1, { x = self.start.x, y = self.start.y })

    self:delay(4, self.F:executeNextAttack())
end

function Sicko:executeNextAttack()
    if #self.attacks == 0 then
        self:prepareForSkateboard()
        self:getThreeRandomAttacks()
        return
    end

    local attack = _.remove(self.attacks, self.attacks:first())
    attack(self)
end

function Sicko:eggsUpdate()
    if _.all(self.eggs, function(e) return e.broken end) then
        self.eggs = nil
        self:toIdleState()
    end
end

function Sicko:shootEggs()
    self.SM:to(MS.Eggs)
    self.eggs = {}
    table.insert(self.eggs, self:spawnEgg(-1))
    self:delay(.3, function()
        table.insert(self.eggs, self:spawnEgg(1))
    end)
end

function Sicko:spawnEgg(direction)
    local x, y = self:center()
    return self.mapLevel:add(Egg(x, y, direction))
end

function Sicko:prepareForLaser()
    self.flip.x = true
    self:delay(1, function() self.flip.x = false end)
    self:tween(1, { x = self.mapLevel.x + 8, y = self.mapLevel.y + 388 })
        :oncomplete(function()
            self.anim:set("sunglasses")
        end)
end

function Sicko:shootLasersHigh()
    self.SFX.laser_long:play("reverb")
    local x, y = self:getRelativePosition(38, 8)
    self.mapLevel:add(Laser(x, y, 1))

    self:delay(1.4, function()
        if self.laserCounter() then
            self:toIdleState()
        elseif self.laserCounter() then
            self:toIdleState()
        else
            if _.chance(self.lowLaserChance) then
                self.highLaserChance = 20
                self.anim:set("laser_to_low")
            else
                self.lowLaserChance = self.lowLaserChance + 10
                self:delay(.5, self.F:shootLasersHigh())
            end
        end
    end)
end

function Sicko:shootLasersLow()
    self.SFX.laser:play("reverb")
    local x, y = self:getRelativePosition(38, 28)
    self.mapLevel:add(Laser(x, y, 1, true))

    self:delay(.4, function()
        if self.laserCounter() then
            self:toIdleState()
        else
            if _.chance(self.highLaserChance) then
                self:delay(.4, function()
                    self.lowLaserChance = 60
                    self.anim:set("laser_to_high")
                end)
            else
                self.highLaserChance = self.highLaserChance + 10
                self:delay(.5, self.F:shootLasersLow())
            end
        end
    end)
end

function Sicko:startBeer()
    self.anim:set("fly_glass")
    self.SM:to(MS.Beer)
end

function Sicko:beerUpdate(dt)
    if self.spillBeer then
        if self.beerTimerSpill(dt) then
            self.spillBeer = not self.spillBeer
            self.anim:set("fly_glass")
            self.flip.x = _.coin()
            local player = _.pick(self.scene:getPlayers(self))
            self.playerTarget = player
            self:lookAt(player)
            self:moveForwardHorizontally(800)
        end
    else
        if self.beerTimerFly(dt) or (self.playerTarget and self:getDistanceX(self.playerTarget) < 20) then
            self.spillBeer = not self.spillBeer
            self.anim:set("fly_glass_fall")
            self:dropBeer()
            self.velocity.x = 0
            self.beerTimerFly()
        end
    end
end

function Sicko:dropBeer()
    self.mapLevel:add(BeerSpill(self:getRelativePosition(2, -4)))
    if self.beerCounter() then
        self.SM:to((MS.Idle))
        self:delay(.5, self.F:toIdleState())
    end
end

function Sicko:startSmoke()
    self.anim:set("fly_smoke")
    self.SM:to(MS.Smoke)
end

function Sicko:smokeUpdate(dt)
    if self.smokeTimer(dt) then
        self:shootSmoke()
    end
end

function Sicko:shootSmoke()
    local x, y = self:getRelativePosition(19, -12)
    local players = self.scene:getPlayers()

    if self.smokePlayer then
        _.remove(players, self.smokePlayer)
    end

    local player = _.pick(players)
    self.smokePlayer = player
    self.mapLevel:add(Smoke(x, y, self:getAngle(player)))

    if self.smokeCounter() then
        self:toIdleState()
    end
end

function Sicko:prepareForSkateboard()
    self.flip.x = false
    self.stopSkateboarding = false
    self.skateboardFinal = false
    self:delay(1, function() self.flip.x = true end)
    self:tween(1, { x = self.mapLevel.x + self.mapLevel.width - 64 - self.width, y = self.mapLevel.y + 388 })
        :oncomplete(function()
            self.SM:to(MS.Skateboard)
            self.anim:set("skateboard_idle")
            self.offset.y = 6
            self.velocity.x = -400
            self.SFX.skateboard_land:play("reverb")
        end)
end

function Sicko:skateboardUpdate()
    if self.skateboardLow then
        local player = self.scene:findNearestPlayer(self)
        if self:getDistanceX(player) < 100 then
            self:skateboardJump()
        end
    end
end

function Sicko:onSkateboardBounce()
    if self.stopSkateboarding then
        self:toIdleState()
        self.stopSkateboarding = false
        return
    end

    if self.skateboardCounter() then
        self.skateboardFinal = true
    end

    if self.skateboardFinal or _.coin() then
        self.skateboardLow = true
        self.anim:set("skateboard_low")
    else
        self.skateboardLow = false
        self.anim:set("skateboard_idle")
    end
end

function Sicko:skateboardJump()
    self.gravity           = 1000
    self.velocity.y        = self.skateboardFinal and -430 or -360
    self.skateboardLow     = false
    self.skateboardJumping = true
    self.anim:set("skateboard_jump")

    self.SFX.skateboard_jump:play("reverb")

    if not self.skateboardFinal then
        return
    end

    if self.scene.music:getSong():tell("seconds") > (174 - 20) then
        self.SFX.guitar[2]:play()
    else
        self.SFX.guitar[1]:play()
    end

    self.slowMo = true
    self:delay(.1, function()
        self.anim:set("skateboard_trick")
        self:delay(.2, self.F({ jumpable = true }))
    end)

    self.slowmoTween = self:tween(.5, { updateSpeed = .05 })
    self.speedUpTween = self.slowmoTween:after(.2, { updateSpeed = 1 })
        :delay(.08)
        :oncomplete(function()
            self.slowmoTween = nil
            self.speedUpTween = nil
        end)

    self:delay(.58, function()
        self.jumpable = false
    end)
end

function Sicko:onSkateboardLand()
    self.SFX.skateboard_land:play("reverb")
    self.skateboardJumping = false
    self.gravity = 0
    self.velocity.y = 0
    self.anim:set("skateboard_idle")
    if self.skateboardFinal then
        self.skateboardFinal = false
        self.stopSkateboarding = true
    end
end

function Sicko:onJumpedOn()
    self:onHit()
end

function Sicko:onHit()
    Enemy.SFX.hit:play("reverb")
    self.sickoText:destroy()
    self.slowmoTween:stop()
    self.speedUpTween:stop()
    self.slowmoTween = nil
    self.speedUpTween = nil

    self.sfxPitch = 1

    self:tween(.5, { sfxPitch = 0.1 })
        :onupdate(function()
            local sounds = self.SFX.guitar[1].sounds
            for i, v in ipairs(sounds) do
                v:setPitch(self.sfxPitch)
                v:setVolume(self.sfxPitch)
            end

            sounds = self.SFX.guitar[2].sounds
            for i, v in ipairs(sounds) do
                v:setPitch(self.sfxPitch)
                v:setVolume(self.sfxPitch)
            end
        end)
        :oncomplete(function()
            local sounds = self.SFX.guitar[1].sounds
            for i, v in ipairs(sounds) do
                v:stop()
                v:setPitch(1)
            end

            sounds = self.SFX.guitar[2].sounds
            for i, v in ipairs(sounds) do
                v:stop()
                v:setPitch(1)
            end
        end)

    self.health = self.health - 1
    if self.health <= 0 then
        self:die()
        return
    end

    Sicko.super.onHit(self)
    self.anim:set("skateboard_hit")
    self.jumpable = false
    self.updateSpeed = 1
    self.stopSkateboarding = true
end

function Sicko:die()
    self:stopMoving("x")

    self.died = true
    self.jumpable = false

    self.velocity.y = 400
    self.updateSpeed = 1
    self.bounce.y = .2
    self.anim:set("dead")
    self.hurtsPlayer = false
    self.offset.y = 6

    self.SM:to(MS.Dead)
    self.z = ZMAP.Peter - 1

    local bp = Blueprint(self:centerX(), self:centerY())
    bp.name = "S1-KO"
    bp.pickupable = false
    bp.gravity = 1000
    bp.velocity.y = -300
    bp.velocity.x = 90
    bp.exclusiveOverlap = false
    bp.exclusiveOverlapCache = false

    bp.onOverlap = function(s, i)
        Blueprint.onOverlap(s, i)

        if i.e.tile then
            s:stopMoving()
            s.accel.y = 0
            s.gravity = 0
        end
    end

    self.mapLevel:add(bp)

    self.room:onSickoDefeated()
end

function Sicko:getThreeRandomAttacks(first)
    self.attacks = list()
    local attackList = self.allAttacks:copy():shuffle()

    if self.attackNotUsedLastRound then
        attackList:removeValue(self.attackNotUsedLastRound)
        self.attacks:add(self.attackNotUsedLastRound)
    end

    if first then
        self.attacks:add(self.prepareForLaser)
        attackList:removeValue(self.prepareForLaser)
    end

    for i = 1, #attackList - 1 do
        local attack = attackList:pick()
        self.attacks:add(attack)
        attackList:removeValue(attack)
    end

    self.attackNotUsedLastRound = attackList:first()
end

return Sicko
