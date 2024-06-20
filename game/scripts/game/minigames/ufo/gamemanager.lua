local levels = require("levels", ...)
local Input = require "base.input"
local HCBox = require "base.hcbox"
local moonshine = require "libs.moonshine"
local Sprite = require "base.sprite"
local Textbox = require("textbox", ...)
local UI = require "minigames.ufo.ui"
local Camera = require "base.camera"
local Shader = require "base.shader"
local Rect = require "base.rect"
local Save = require "base.save"
local Music = require "base.music"
local Scene = require "base.scene"

local GameManager = Scene:extend("GameManager")

function GameManager:new(levelsToBeat, minigame)
    GameManager.super.new(self, 0, 0, 480, 270)
    self:setBackgroundColor(10, 10, 10)
    self.origin:set(0, 0)
    self.scale:set(2)

    self.minigame = minigame

    self.z = -120

    self:addHC()

    self.camera:setWindow(0, 0, 480, 270)
    self.camera.lerp = 6

    self.minimap = Camera(0, 0, 460, 270)
    self.minimap:zoomTo(.2)
    self.minimap:setWindow(792, 262, 150, 150)
    self.minimap.lerp = 6

    self.forward = Sprite()
    self.forward.width = 2
    self.forward.height = 2
    self.forward.offset = { x = 0, y = 0 }

    self.boxes = list()

    self.textbox = self:addOverlay(Textbox())

    self.removeOnLevelChange = true

    self.transitionRects = list()
    for i = 0, 10 do
        for j = 0, 9 do
            local rect = self.transitionRects:add(self:addOverlay(Rect(j * self.width / 10, i * self.height / 10,
                self.width / 10,
                self.height / 10)))
            rect:setColor(10, 10, 10)
        end
    end

    Save:set("game.spacer_racer.deaths.level", 0)

    self.ui = self:addOverlay(UI(minigame))
    self.ui:appear()

    self.levelsToBeat = levelsToBeat

    self.levelsBeaten = 0

    self:setMap("ufo")
    self:setLevel(self.levelsToBeat[self.levelsBeaten + 1])

    self.camera:follow(self.forward, true)
    self.minimap:follow(self.forward, true)

    self.minimapShader = Shader.new("monochrome")

    self.ui:setMinimapCamera(self.camera)

    self.effects = moonshine(moonshine.effects.scanlines)
    self.effects.scanlines.thickness = 1
    self.effects.scanlines.opacity = 0.1
    self.effects.scanlines.frequency = 200
    self.showEffects = true

    self.startedRace = false
    self.timer = 0

    self.finished = false

    self.starsPickedUp = 0

    self.music = Music("music/minigames/spacer_racer")

    self.timerIncreaseInterval = step.every(1)
end

function GameManager:update(dt)
    if self.startedRace then
        self.timer = self.timer + dt

        if self.timerIncreaseInterval(dt) then
            Save:increase("game.spacer_racer.time")
        end
    end

    self.music:update(dt)

    GameManager.super.update(self, dt)

    self.offStars1.offset.x = (self.camera.x - self.level.x) * 0.8 + self.level.x - 300
    self.offStars1.offset.y = (self.camera.y - self.level.y) * 0.8 + self.level.y - 300

    self.offStars2.offset.x = (self.camera.x - self.level.x) * 0.7 + self.level.x - 300
    self.offStars2.offset.y = (self.camera.y - self.level.y) * 0.7 + self.level.y - 300
end

function GameManager:updateCamera(dt)
    if self.ufo.accel.x == 0 then
        self.forward.offset.x = _.lerp(self.forward.offset.x, 0, dt * 2)
    end

    if self.ufo.accel.y == 0 then
        self.forward.offset.y = _.lerp(self.forward.offset.y, 0, dt * 2)
    end

    self.forward.offset.x = _.clamp(self.forward.offset.x + self.ufo.velocity.x * dt, -40, 40)
    self.forward.offset.y = _.clamp(self.forward.offset.y + self.ufo.velocity.y * dt, -40, 40)

    self.forward.x = self.ufo:centerX() + (self.ui.width / 2) + self.forward.offset.x
    self.forward.y = self.ufo:centerY() + self.forward.offset.y

    self.minimap:update(dt)

    GameManager.super.updateCamera(self, dt)
end

function GameManager:draw()
    GameManager.super.draw(self)

    if not self.ui.showing then
        return
    end

    if self.ui.screen.visible then
        return
    end

    if self.finished or not self.startedRace then
        return
    end

    self.offStars1.visible = false
    self.offStars2.visible = false

    love.graphics.push("all")
    love.graphics.setShader(self.minimapShader)
    self.minimap:draw(function()
        self:drawInCamera()
    end)
    love.graphics.pop()

    self.offStars1.visible = true
    self.offStars2.visible = true
end

function GameManager:startDialogue(dialogueData, onComplete)
    self.textbox:appear(dialogueData, onComplete)
end

function GameManager:onChangingLevel(level)
    GameManager.super.onChangingLevel(self, level)
    self.level = level
    self.levelNumber = tonumber(level.id:split("_")[3])
    local levelData = levels[self.levelNumber]
    self.finished = false
    self.startedRace = false

    Save:set("game.spacer_racer.deaths.level", 0)

    self.timer = 0
    self.timeToBeat = self.minigame and Save:get("minigames.sr_times")[self.levelNumber + 1] or levelData.timeToBeat
    self.ui:updateTimeToBeat(self.timeToBeat)

    self.ui:disappear()

    self:delay(1.2, function()
        -- FINAL: Remove false and
        if not self.minigame and levelData.dialogue then
            self:startDialogue(levelData.dialogue, function()
                self.ui:appear()
                self.ufo.inControl = true
            end)
        else
            self.ui:appear()
            self.ufo.inControl = true
        end
    end)

    for i, v in ipairs(self.entities) do
        if v.tile then
            for j, w in ipairs(v.hitboxList) do
                self.boxes:add(HCBox(v, self.HC, HCBox.Shape.Rectangle, w.bb.x, w.bb.y, w.width, w.height))
            end
            if v.enum ~= "Safe" then
                v:clearHitboxes()
            end
        end
    end

    self:moveCameraToLevel(level)

    self.offStars1 = self:add(Sprite(0, 0, "minigames/ufo/stars"))
    self.offStars1.z = 200
    self.offStars1.removeOnLevelChange = true
    self.offStars2 = self:add(Sprite(0, 0, "minigames/ufo/stars"))
    self.offStars2.angle = PI / 2
    self.offStars2.z = 200
    self.offStars2.removeOnLevelChange = true

    self.ui:updateDeathCounters()

    for i, v in ipairs(self.transitionRects) do
        self:delay(i * .01, function() v.visible = false end)
    end

    local ufos = self:findEntitiesWithTag("Ufo")
    self.ufo = ufos:last()
    self.forward:set(self.ufo:center())
    self.camera:follow(self.forward, true)
    self.minimap:follow(self.forward, true)
    self.camera.followPoint.x = math.floor(self.camera.followPoint.x)
    self.camera.followPoint.y = math.floor(self.camera.followPoint.y)
end

function GameManager:moveCameraToLevel(level)
    local x, y, w, h = level.x, level.y, level.width, level.height - 36
    self.camera:setWorld(x, y, w, h)
    self.minimap:setWorld(x, y, w, h)
end

function GameManager:startRace()
    if self.startedRace then
        return
    end

    self.startedRace = true
    self.timer = 0
    self.entities:onRaceStart()

    self.music:play("" .. self.levelNumber, nil, true):setLooping(false)
end

function GameManager:resetRace()
    self.startedRace = false
    self.entities:onRaceReset()
    self.ufo:respawn()
    self.finished = false
    self.ufo.inControl = true
    self.starsPickedUp = 0
    self.music:stop()
    collectgarbage()
end

function GameManager:onFinish()
    if self.finshed then return end
    self.startedRace = false
    self.finished = true
    self.ufo.inControl = false

    if self.timer >= self.timeToBeat then
        self.finishedInTime = false
        self:delay(2, function()
            self:resetRace()
        end)
    else
        self.finishedInTime = true

        local times = Save:get("minigames.sr_times")
        times[self.levelNumber + 1] = self.timer
        Save:set("minigames.sr_times", times)
        Save:save()

        if self.minigame then
            self.timeToBeat = self.timer
            self.ui:updateTimeToBeat(self.timeToBeat)
            self:delay(2, function()
                self:resetRace()
            end)
            return
        end

        self.levelsBeaten = self.levelsBeaten + 1

        for i, v in ipairs(self.transitionRects) do
            self:delay(2 + i * .01, function() v.visible = true end)
        end

        self.music:stop(3.5)
        self:delay(4, function()
            if #self.levelsToBeat == self.levelsBeaten then
                self.scene:onBeatingUfoGame()
                self:destroy()
            else
                self.HC:init()
                self:setLevel(self.levelsToBeat[self.levelsBeaten + 1])
            end
        end)
    end
end

function GameManager:toNextLevel()
    self.levelsBeaten = self.levelsBeaten + 1
    self:setLevel(self.levelsToBeat[self.levelsBeaten + 1])
end

function GameManager:toPreviousLevel()
    self.levelsBeaten = self.levelsBeaten - 1
    if self.levelsBeaten < 0 then
        self.levelsBeaten = 0
    end
    self:setLevel(self.levelsToBeat[self.levelsBeaten + 1])
end

function GameManager:onPickingUpStar()
    self.starsPickedUp = self.starsPickedUp + 1
    local door = self:findNearestEntity(self.ufo, function(e) return e.tag == "Door" end)

    if door.stars <= self.starsPickedUp then
        door:open()
        self.starsPickedUp = self.starsPickedUp - door.stars
    end
end

function GameManager:increaseDeathCounters()
    if not self.minigame then
        Save:increase("game.spacer_racer.deaths.level", 1)
        Save:increase("game.spacer_racer.deaths.total", 1)
        Save:save()
        self.ui:updateDeathCounters()
    else
        self.ui:increaseDeathCounter()
    end
end

return GameManager
