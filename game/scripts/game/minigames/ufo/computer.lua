local Point = require "base.point"
local Entity = require "base.entity"
local HCbox = require "base.hcbox"
local Scene = require "base.scene"

local Computer = Scene:extend("Computer")

function Computer:new(...)
    Computer.super.new(self, ...)
    self.useStencil = true
    self:setBackgroundAlpha(0)

    self.timer = 0

    self.innerCircleRadius = 50
    self.innerCircleRadiusDefault = 75
    self.glowSize = 0

    -- Eye
    self.eye = Point(0, 0)
    self.eyeMoveTimer = step.every(1, 3)
    self.eyeSizeTimer = step.every(1, 3)
    self.eyeRadius = 20

    -- Voice
    self.voicePoints = {}

    local amount = 30
    for i = 0, amount do
        table.insert(self.voicePoints,
            Point(WIDTH / 2 - self.innerCircleRadius + i * (self.innerCircleRadius / amount) * 2, HEIGHT / 2))
    end
    self.voiceTimer = step.every(.1, .3)
    self.speed = 1

    self.mode = "eye"
    self:center(self.x, self.y)

    self.moveTowardsPlayers = false
    self.followPoint = Point()
    self.followPointNext = Point()
    self.start = Point(self.x, self.y)

    self.getNewFollowTimer = step.every(.5)
    self.getNewFollowTimer:finish()

    self.isDangerous = true
    self.movementAngle = 0

    self.speed = 160
    self.rotationSpeed = .5
    self.z = 150

    -- self.speed = 150
    -- self.rotationSpeed = .4
end

function Computer:done()
    Computer.super.done(self)
    -- TODO: Fix that computer can collide with the player upon respawn
    -- The computer, and the HCBox, can appear in the starting area, and are moved from there too late.
    -- UPDATE: I think this is fixed now, but I'm not sure.
    self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Circle, self.x, self.y, self.innerCircleRadiusDefault)
end

function Computer:update(dt)
    Computer.super.update(self, dt)
    self.hcbox:update(dt)

    self.timer = self.timer + dt

    self.radiusGrowSpeed = 50

    if self.mode == "eye" then
        if self.eyeMoveTimer(dt) then
            self:tween(self.eye, .5, { x = _.random(-10, 10), y = _.random(-10, 10) })
        end

        if self.eyeSizeTimer(dt) then
            self:tween(self, _.random(.3, .8), { eyeRadius = _.random(10, 35) })
        end

        self.innerCircleRadius = self.innerCircleRadiusDefault + _.sin(self.timer * .5) * 3
    elseif self.mode == "voice" then
        if self.voiceTimer(dt) then
            self:speak()
        end
    end

    if self.getNewFollowTimer(dt) then
        local ufo = self.scene:findEntityWithTag("Ufo")
        if ufo then
            self.followPoint:clone(self.followPointNext)
            self.followPointNext:set(ufo:center())
        end
    end

    if self.moveTowardsPlayers then
        local ufo = self.scene:findEntityWithTag("Ufo")
        if ufo then
            local angle = self:getAngle(self.followPoint)
            self.movementAngle = _.rotate(self.movementAngle, angle, dt * self.rotationSpeed)
            self.x = self.x + math.cos(self.movementAngle) * self.speed * dt
            self.y = self.y + math.sin(self.movementAngle) * self.speed * dt
        end
    end
end

function Computer:drawInCamera()
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(2)
    self:drawRadialLines(WIDTH / 2, HEIGHT / 2, self.innerCircleRadius + 15,
        self.innerCircleRadius + 5, 20,
        _.sin(self.timer * PI * .1) * -PI * .5)
    self:drawRadialLines(WIDTH / 2, HEIGHT / 2, self.innerCircleRadius + 15,
        self.innerCircleRadius + 10, 80,
        _.sin(self.timer * PI * .1) * -PI * .5)
    love.graphics.circle("line", WIDTH / 2, HEIGHT / 2, self.innerCircleRadius + 16)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", WIDTH / 2, HEIGHT / 2, self.innerCircleRadius)

    if self.mode == "eye" then
        self:drawEye()
    elseif self.mode == "voice" then
        self:drawVoice()
    end

    Computer.super.drawInCamera(self)
end

function Computer:drawRadialLines(cx, cy, innerRadius, outerRadius, numLines, offset)
    -- Calculate the angle step for each line based on the number of lines
    local angleStep = (2 * PI) / numLines

    for i = 0, numLines - 1 do
        -- Calculate the current angle
        local angle = i * angleStep + offset

        -- Calculate the start (inner) and end (outer) positions of the line
        local startX = cx + innerRadius * math.cos(angle)
        local startY = cy + innerRadius * math.sin(angle)
        local endX = cx + outerRadius * math.cos(angle)
        local endY = cy + outerRadius * math.sin(angle)

        -- Draw the line
        love.graphics.line(startX, startY, endX, endY)
    end
end

function Computer:drawEye()
    local r, g, b = 124 / 255, 98 / 255, 120 / 255

    love.graphics.setColor(r, g, b, .25)
    love.graphics.setLineWidth(2)
    self:drawRadialLines(WIDTH / 2 + self.eye.x * .5, HEIGHT / 2 + self.eye.y * .5, self.innerCircleRadius - 10,
        self.innerCircleRadius - 20, 50,
        _.sin(self.timer * PI * .25) * PI * .5)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(r, g, b, .5)
    self:drawRadialLines(WIDTH / 2 + self.eye.x * .75, HEIGHT / 2 + self.eye.y * .75, self.innerCircleRadius - 25,
        self.innerCircleRadius - 35, 25,
        _.sin(self.timer * PI * .5) * -PI * .5)

    love.graphics.setLineWidth(2)
    love.graphics.setColor(r, g, b, 1)
    love.graphics.circle("line", WIDTH / 2 + self.eye.x, HEIGHT / 2 + self.eye.y, self.eyeRadius, 100)
    love.graphics.setColor(1, 1, 1, 1)
end

function Computer:drawVoice()
    local r, g, b = 124 / 255, 98 / 255, 120 / 255
    local line = {}
    for i, v in ipairs(self.voicePoints) do
        table.insert(line, v.x)
        table.insert(line, v.y)
    end

    love.graphics.setColor(r, g, b, .5)
    love.graphics.setLineWidth(3)
    love.graphics.line(line)
    love.graphics.setColor(1, 1, 1, 1)
end

function Computer:onRaceReset()
    self.moveTowardsPlayers = false
    self.x = self.start.x
    self.y = self.start.y
end

function Computer:onRaceStart()
    self.moveTowardsPlayers = true
    self.movementAngle = -PI / 2
    self.getNewFollowTimer:finish()
end

return Computer
