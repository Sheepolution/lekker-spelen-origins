local StateManager = require "base.statemanager"
local Enum = require "libs.enum"
local QuestionMark = require("questionmark", ...)
local Enemy = require "creatures.enemy"
local Barrel = require("barrel", ...)
local Fist = require("fist", ...)
local SFX = require "base.sfx"
local Sprite = require "base.sprite"

local Konkie = Enemy:extend("Konkie")

local MS = Enum({
    "Idle",
    "Hurt",
    "Fists",
    "Barrels",
    "QuestionMarks"
})

Konkie.MS = MS

Konkie.SFX = {
    angry = SFX("sfx/bosses/konkie/steam")
}

local SlamMode = Enum("Player", "Sweep")

function Konkie:new(...)
    Konkie.super.new(self, ...)
    self:setImage("bosses/konkie/konkie", true)
    self.anim:getAnimation("barrel"):onFrame(12, function() self:throwBarrel() end)

    self.head = Sprite(0, 0, "bosses/konkie/konkie_head", true)

    self:centerX(self.x + WIDTH / 2)
    self.y = self.y + 10
    self:setStart()

    self.solid = 0
    self.anim:set("idle_no_fists")
    self.head.anim:set("idle")

    self:addHitbox("solid", 0, -120, 170, 170)

    self.qmTimer = step.new(1)
    self.healthMax = 500
    self.health = self.healthMax
    self.segmentStartHealth = self.health

    self.blinkTimer:finish(true)

    self.slamMode = SlamMode.Player
    self.slamCount = count.new(5, true)
    self.playerSlamDelay = step.every(1.3)

    self.SM = StateManager(self, { MS })
    self.SM:to(MS.Idle)
    self.lastMS = MS.Fists

    self.stateNumber = 0
    self.stateList = { MS.Fists, MS.QuestionMarks, MS.Barrels }
end

function Konkie:done()
    self.rightFist = self.mapLevel:add(Fist(self, 160, self:centerY()))
    self.leftFist = self.mapLevel:add(Fist(self, -160, self:centerY(), true))
    self.fists = list({ self.rightFist, self.leftFist })
end

function Konkie:update(dt)
    self.SM:update(dt)

    if self.head.singleColor then
        if self.blinkTimer(dt) then
            self.head.singleColor = nil
        end
    end

    self.head:update(dt)

    Konkie.super.update(self, dt)
end

function Konkie:draw()
    Konkie.super.draw(self)
    self.head:drawAsChild(self)
end

function Konkie:onLaserHit()
    Konkie.super.onLaserHit(self)
    local missing = self.segmentStartHealth - self.health
    if missing > 150 then
        self:becomeConfused()
        self.segmentStartHealth = self.health - 25
    end
end

function Konkie:blinkWhite()
    if not self.blinkWhiteDelay(0) then
        self.head.singleColor = { 255, 255, 255 }
        self.blinkTimer()
        self.blinkWhiteDelay()
    end
end

function Konkie:barrelsInit()
    self.anim:set("barrel")
    self.head.anim:set("barrel")
end

function Konkie:throwBarrel()
    local barrel = self.mapLevel:add(Barrel())
    barrel:center(self:center())
end

function Konkie:fistsInit()
    self.fists(function(e) e.visibile = true end)
end

function Konkie:fistsUpdate(dt)
    if self.slamMode == SlamMode.Player then
        if self.playerSlamDelay(dt) then
            if self.slamCount() then
                self.slamMode = SlamMode.Sweep
                self:startSlamSweep(_.scoin())
            else
                self:handlePlayerSlamming()
            end
        end
    end
end

function Konkie:startSlamSweep(direction)
    self.fists:moveToTheSide(-direction)

    self.sweepTween = self:tween(1.6, { x = self.start.x + 100 * -direction }):oncomplete(function()
        self.sweepEvent = self:event(function(i)
            self.fists:slam(3)
            self.coil.wait(.5)

            if i == 5 then
                self:tween(.5, { x = self.start.x })
                self.fists:moveBackToStart()
                self.coil.wait(.5)
                self.slamMode = SlamMode.Player
                self.sweepEvent = nil
                return
            end

            self:tween(.2, { x = self.x + 60 * direction })
            self.fists:moveABit(direction)
            -- NOTE: If konkie is messed up it's because you changed this from .5 to .2 (and in moveABit as well)
            self.coil.wait(.2)
        end, 0, 5)
    end)
end

function Konkie:handlePlayerSlamming()
    local player = _.pick(self.scene:getPlayers())
    local pcx = player:centerX()
    if pcx < self:centerX() then
        local to_x = pcx - self.width / 2 + _.random(100, 300)
        to_x = _.floor(_.clamp(to_x, self.start.x - 100, self.start.x + 100))
        self:tween(.5, { x = to_x })
        self.leftFist:moveToPlayer(pcx, to_x + self.width / 2)
        self.rightFist:moveBackToStart()
    else
        local to_x = pcx - self.width / 2 - _.random(100, 300)
        to_x = _.floor(_.clamp(to_x, self.start.x - 100, self.start.x + 100))
        self:tween(.5, { x = to_x })
        self.rightFist:moveToPlayer(pcx, to_x + self.width / 2)
        self.leftFist:moveBackToStart()
    end
end

function Konkie:becomeConfused()
    if self.SM:is(MS.Fists) then
        self.fists:destroy()
    end
    self:tween(.5, { x = self.start.x })
    self.anim:set("confused")
    self.head.anim:set("confused")
    if not self.SM:is(MS.Barrels) then
        self.room:onKonkieNextPhase()
        self:delay(3, self.F:becomeAngry())
    else
        self.room:onKonkieDefeated()
    end

    if self.sweepTween then
        self.sweepTween:stop()
        self.sweepTween = nil
    end

    if self.sweepEvent then
        self.sweepEvent:stop()
        self.sweepEvent = nil
    end

    self.SM:to(MS.Hurt)
end

function Konkie:becomeAngry()
    self.SFX.angry:play("reverb")
    self.anim:set("angry")
    self.head.anim:set("angry")
    self:delay(2, self.F:toNextState())
end

function Konkie:questionMarksInit()
    self.anim:set("book_grab")
    self.head.anim:set("book_grab")
end

function Konkie:questionMarksUpdate(dt)
    if self.qmTimer(dt) then
        local y = _.random(50, 300)
        self.mapLevel:add(QuestionMark(self:centerX() + _.scoin() * _.random(200, 300), self.y + y, y > 200))
    end
end

function Konkie:toNextState()
    self.stateNumber = self.stateNumber + 1
    local state = self.stateList[self.stateNumber]
    self.lastMS = state
    self.SM:to(state)
end

function Konkie:kill()

end

return Konkie
