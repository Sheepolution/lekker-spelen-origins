local Sprite = require "base.sprite"
local FlagManager = require "flagmanager"
local PeterOnTimon = require "characters.players.peter_on_timon"
local Scene = require "base.scene"

local ExitRoom = Scene:extend("ExitRoom")

function ExitRoom:new(x, y, mapLevel)
    ExitRoom.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function ExitRoom:done()
    self.background:add("flora/set/5", 1756, 2656, true)
    self.background:add("flora/set/1", 1659, 2675)
    self.background:add("flora/set/9", 1527, 2675)
    self.background:add("flora/set/7", 1568, 2656)
    self.background:add("flora/set/6", 1619, 2688)
    self.background:add("flora/set/2", 1365, 2688)
    self.background:add("flora/set/3", 1101, 2685)
    self.background:add("flora/set/8", 1310, 2687)
    self.background:add("plafond_slierten4", 1558, 2552)
    self.background:add("plafond_slierten2", 1620, 2552)
    self.background:add("plafond_slierten3", 1710, 2552)
    self.background:add("bord_nooduitgang_rechts", 1658, 2596)

    self.button = self.mapLevel:add(Sprite(0, self.mapLevel.y + 424, "bosses/konkie/button", true))
    self.button:centerX(self.x + WIDTH / 2 - 100)
    self.button.z = 99
    self.button.anim:set("off")

    self.timer = 62

    if FlagManager:get(Enums.Flag.cutsceneSelfDestruct) then
        self.scene:onInitializingBoss()
        self:delay(.01, function()
            self:initializeRestart()
        end)
    end
end

function ExitRoom:update(dt)
    ExitRoom.super.update(self, dt)

    if self.reachedExit then
        if self.scene.timon then
            if self.scene.timon:left() > self.mapLevel:right() then
                self.scene.timon:destroy()
                self.scene.timon = nil
            end
        end
        return
    end

    if self.scene.timon:right() > self.mapLevel:right() then
        self.reachedExit = true
        self.countingDown = false
        self.timer = 1000
        self.scene.timon.inControl = false
        self.scene:fadeOut(1, function()
            self.scene:goToEnding()
            self.scene:setLevel("Empty")
        end)
    end

    if self.countingDown then
        self.timer = self.timer - dt
        if self.timer < 0 then
            self.scene.timon:die()
        end
    end
end

function ExitRoom:startCountdown()
    self.scene.music:play("cutscenes/self_destruct/countdown", nil, true)
    self.countingDown = true
end

function ExitRoom:initializeRestart()
    self.scene.noDoorAccess = true
    local level = self.scene:getLevel()
    self.scene.peter:destroy()
    self.scene.timon:destroy()
    self.scene.timon = level:add(PeterOnTimon(self.scene.peter:centerX(), self.scene.timon:centerY() - 5))
    self.scene.peter = nil
    self:startCountdown()
end

return ExitRoom
