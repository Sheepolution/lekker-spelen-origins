local Input = require "base.input"
local Scene = require "base.scene"

local GameManager = Scene:extend("GameManager")

function GameManager:new()
    GameManager.super.new(self, 0, 0, 480, 270)

    self:setMap("test")
    self:setLevel(self.levelsToBeat[self.levelsBeaten + 1])

    self.camera:follow(self.forward, true)
    self.minimap:follow(self.forward, true)

    self.minimapShader = Shader.new("monochrome")

    self.UI:setMinimapCamera(self.camera)

    self.effects = moonshine(moonshine.effects.scanlines)
    self.effects.scanlines.thickness = 1
    self.effects.scanlines.opacity = 0.1
    self.effects.scanlines.frequency = 200

    self.startedRace = false
    self.timer = 0

    self.finished = false
end

function GameManager:update(dt)
    if self.startedRace then
        self.timer = self.timer + dt
    end

    if Input:isPressed("p") then
        self:toNextLevel()
    end

    if Input:isPressed("o") then
        self:toPreviousLevel()
    end

    GameManager.super.update(self, dt)

    self.offStars1:foreach(function(e)
        e.offset.x = self.camera.x * 0.8 + self.level.x * 0.2
        e.offset.y = self.camera.y * 0.8 + self.level.y * 0.2
    end)

    self.offStars2:foreach(function(e)
        e.offset.x = self.camera.x * 0.7 + self.level.x * 0.3
        e.offset.y = self.camera.y * 0.7 + self.level.y * 0.3
    end)
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

    self.forward.x = self.ufo:centerX() + self.forward.offset.x
    self.forward.y = self.ufo:centerY() + self.forward.offset.y

    self.minimap:update(dt)

    GameManager.super.updateCamera(self, dt)
end

function GameManager:draw()
    GameManager.super.draw(self)

    if not self.UI.showing then
        return
    end

    if self.UI.screen.visible then
        return
    end

    if self.finished or not self.startedRace then
        return
    end

    self.offStars1:foreach(function(e)
        e.visible = false
    end)

    self.offStars2:foreach(function(e)
        e.visible = false
    end)

    love.graphics.push("all")
    love.graphics.setShader(self.minimapShader)
    self.minimap:draw(function()
        self:drawInCamera()
    end)
    love.graphics.pop()

    self.offStars1:foreach(function(e)
        e.visible = true
    end)

    self.offStars2:foreach(function(e)
        e.visible = true
    end)
end

function GameManager:drawInCamera()
    GameManager.super.drawInCamera(self)
    -- self.boxes:draw()
end

function GameManager:startDialogue(dialogueData, onComplete)
    -- self.textbox:appear(dialogueData, onComplete)
    onComplete()
end

function GameManager:onChangingLevel(level)
    self.level = level
    local levelData = levels[level.id]

    self.finished = false
    self.startedRace = false

    self.timer = 0
    self.timeToBeat = levelData.timeToBeat
    self.UI:updateTimeToBeat(self.timeToBeat)

    self.UI:disappear()

    self:delay(1.2, function()
        if levelData.dialogue then
            self:startDialogue(levelData.dialogue, function()
                self.UI:appear()
                self.ufo.inControl = true
            end)
        else
            self.UI:appear()
        end
    end)

    for i, v in ipairs(self.entities) do
        if v.tile then
            for j, w in ipairs(v.hitboxList) do
                self.boxes:add(HCBox(v, self.HC, HCBox.Shape.Rectangle, w.bb.x, w.bb.y, w.width, w.height))
            end
        end
    end

    self:moveCameraToLevel(level)

    self.offStars1:destroy()
    self.offStars2:destroy()

    for i = 1, 1000 do
        local r = self.offStars1:add(self:add(Sprite(_.random(-200, level.width + 400),
            _.random(-200, level.height + 400))))
        r.width = 1
        r.height = 1
        r.z = 200

        if i % 2 == 0 then
            r = self.offStars2:add(self:add(Sprite(_.random(-200, level.width + 400),
                _.random(-200, level.width + 400))))
            r.width = 1
            r.height = 1
            r.z = 200
        end
    end

    for i, v in ipairs(self.transitionRects) do
        self:delay(i * .01, function() v.visible = false end)
    end

    local ufos = self:findEntitiesWithTag("Ufo")
    self.ufo = ufos:last()
    self.forward:set(self.ufo:center())
    self.camera:follow(self.forward, true)
    self.minimap:follow(self.forward, true)
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
end

function GameManager:resetRace()
    self.startedRace = false
    self.entities:onRaceReset()
    self.ufo:respawn()
    self.finished = false
    self.ufo.inControl = true
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
        self.levelsBeaten = self.levelsBeaten + 1
        self.finishedInTime = true

        for i, v in ipairs(self.transitionRects) do
            self:delay(2 + i * .01, function() v.visible = true end)
        end

        self:delay(4, function()
            if #self.levelsToBeat == self.levelsBeaten then
                self.scene:onBeatingUfoGame()
            else
                self:setLevel(self.levelsToBeat[self.levelsBeaten + 1])
            end
        end)
    end
end

function GameManager:toNextLevel()
    self.levelsBeaten = self.levelsBeaten + 1
    self:setLevel(self.levelsToBeat[self.levelsBeaten])
end

function GameManager:toPreviousLevel()
    self.levelsBeaten = self.levelsBeaten - 1
    if self.levelsBeaten < 1 then
        self.levelsBeaten = 1
    end
    self:setLevel(self.levelsToBeat[self.levelsBeaten])
end

return GameManager
