local Sprite = require "base.sprite"
local Text = require "base.text"
local Scene = require "base.scene"

local UI = Scene:extend("UI")

local Save = require "base.save"

function UI:new(minigame)
    UI.super.new(self, WIDTH / 2, 0, 96, 270)
    self:setBackgroundImage("minigames/ufo/ui/background")
    self.peter = self:add(Sprite(12, 8, "minigames/ufo/ui/peter", true))
    self.timon = self:add(Sprite(52, 8, "minigames/ufo/ui/timon", true))

    self.textDeathsLevel = self:addOverlay(Text(30, 92, Save:get("spacer_racer.deaths.level") or "0"))
    self.textDeathsLevel:setColor(123, 255, 48)
    self.textDeathsLevel:setAlign("center", 200)

    self.textDeathsTotal = self:addOverlay(Text(70, 92,
        Save:get("spacer_racer.deaths.total") or (minigame and "-" or "0")))
    self.textDeathsTotal:setColor(123, 255, 48)
    self.textDeathsTotal:setAlign("center", 200)

    self.screen = self:add(Sprite(12, 131, "minigames/ufo/ui/screen", true))

    self.textTimer = self:addOverlay(Text(27, 228, "00:00.12"))
    self.textTimer:setColor(123, 255, 48)

    self.textTimerToBeat = self:addOverlay(Text(27, 246, "01:00.00"))
    self.textTimerToBeat:setColor(123, 255, 48)

    self.dangerTimer = step.during(1)
    self.dangerTimer:finish()

    self.showing = false
    self.showX = 384
    self.hideX = self.x

    self.deathCounter = 0

    self.minigame = minigame

    self:updateDeathCounters()
end

function UI:update(dt)
    local ufo = self.scene.ufo

    if ufo.inDanger then
        self.dangerTimer()
    end

    self.screen.visible = false

    if self.scene.finished then
        local anim = self.scene.finishedInTime and "yay" or "sad"
        self.peter.anim:set(anim)
        self.timon.anim:set(anim)
        self.screen.visible = true
        self.screen.anim:set(self.scene.finishedInTime and "flag" or "sad")
    elseif self.scene.ufo.died then
        self.dangerTimer:finish()
        self.peter.anim:set("dead")
        self.timon.anim:set("dead")
    elseif self.dangerTimer:update(dt) then
        self.peter.anim:set("scared")
        self.timon.anim:set("scared")
        self.screen.visible = true
        self.screen.anim:set("warning")
    else
        self.screen.visible = false
        if ufo.accel.x < 0 then
            self.peter.anim:set("left")
        elseif ufo.accel.x > 0 then
            self.peter.anim:set("right")
        else
            self.peter.anim:set("front")
        end

        if ufo.accel.y < 0 then
            self.timon.anim:set("up")
        elseif ufo.accel.y > 0 then
            self.timon.anim:set("down")
        else
            self.timon.anim:set("front")
        end
    end

    self.textTimer:write(_.clockMMSSmm(self.scene.timer))

    UI.super.update(self, dt)
end

function UI:draw()
    UI.super.draw(self)
end

function UI:setMinimapCamera()
    self.minimapCamera = self.camera
end

function UI:appear()
    self:tween(.4, { x = self.showX }):oncomplete(function()
        self.showing = true
    end)
end

function UI:disappear()
    self.showing = false
    self:tween(.4, { x = self.hideX })
end

function UI:updateTimeToBeat(time)
    self.textTimer:write("00:00.00")
    self.textTimerToBeat:write(_.clockMMSSmm(time))
end

function UI:updateDeathCounters()
    if not self.minigame then
        self.textDeathsLevel:write(Save:get("game.spacer_racer.deaths.level") or "0")
        self.textDeathsTotal:write(Save:get("game.spacer_racer.deaths.total") or "0")
    end
end

function UI:increaseDeathCounter()
    self.deathCounter = self.deathCounter + 1
    self.textDeathsLevel:write(self.deathCounter)
end

return UI
