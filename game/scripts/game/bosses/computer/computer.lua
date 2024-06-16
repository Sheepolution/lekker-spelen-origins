local Point = require "base.point"
local Asset = require "base.asset"
local moonshine = require "libs.moonshine"
local Sprite = require "base.sprite"
local Text = require "base.text"
local Rect = require "base.rect"
local Waku = require("waku", ...)
local Interactable = require "interactables.interactable"
local FloorButton = require "interactables.floorbutton"
local Button = require "interactables.button"
local Input = require "base.input"
local Video = require "base.video"
local Scene = require "base.scene"

local Computer = Scene:extend("Computer")

function Computer:new(...)
    Computer.super.new(self, ...)
    self.useStencil = true
    self:setBackgroundImage("bosses/computer/background")

    -- Hexagon grid
    self.grid1 = Sprite(0, 0, "bosses/computer/hexagon_grid1")
    self.grid2 = Sprite(0, 0, "bosses/computer/hexagon_grid2")
    self:setBackgroundAlpha(0)
    self.timer = 0

    self.hexagons = list()

    for i = 1, 50 do
        local hexagon = self.hexagons:add(Sprite(4, 8, "bosses/computer/hexagon"))
        self:placeHexagonOnRandomPosition(hexagon)
        local f
        f = function()
            self:tween(hexagon, _.random(.5, 2), { alpha = 0 }):oncomplete(function()
                self:placeHexagonOnRandomPosition(hexagon)
            end):after(_.random(.5, 2), { alpha = 1 }):delay(_.random(2)):oncomplete(f)
        end
        f()
    end

    self.mode = "eye"

    self.turningOn = false

    -- Circle
    self.ringRadius1 = 0
    self.ringRadius2 = 250

    self.innerCircleRadius = 100
    self.innerCircleRadiusDefault = 100
    self.glowSize = 0

    -- Eye
    self.eye = Point(0, 0)
    self.eyeMoveTimer = step.every(1, 3)
    self.eyeSizeTimer = step.every(1, 3)
    self.eyeRadius = 30

    -- Voice
    self.voicePoints = {}

    local amount = 30
    for i = 0, amount do
        table.insert(self.voicePoints,
            Point(WIDTH / 2 - self.innerCircleRadius + i * (self.innerCircleRadius / amount) * 2, HEIGHT / 2))
    end
    self.voiceTimer = step.every(.1, .3)

    self.blur = moonshine(moonshine.effects.boxblur)
    self:addShader("rgb")

    self.canvas:setFilter("linear", "linear")

    -- Timer for starting rgb effect
    self.rgbTimerStart = step.after(.5, 3)

    -- Timer for changing direction
    self.rgbTimerDirection = step.every(.1, .5)

    -- Timer for duration of rgb effect
    self.rgbTimerOff = step.once(.4, .8)

    self:send("amount", 0)

    self.dust = love.graphics.newParticleSystem(Asset.image("bosses/computer/particle"), 1000)

    self.dust:setColors(1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0.5, 1, 1, 1, 0)
    self.dust:setDirection(-1.5707963705063)
    self.dust:setEmissionArea("uniform", 483.93194580078, 10, 0, false)
    self.dust:setEmissionRate(163.72982788086)
    self.dust:setInsertMode("top")
    self.dust:setLinearAcceleration(-4.133960723877, -0.051036551594734, 26.998336791992, -11.4832239151)
    self.dust:setLinearDamping(-0.00020414621394593, 0.00020414621394593)
    self.dust:setOffset(4.5, 4.5)
    self.dust:setParticleLifetime(1.8350294828415, 7.2860903739929)
    self.dust:setRadialAcceleration(-8.2679214477539, 12.350845336914)
    self.dust:setRelativeRotation(false)
    self.dust:setSizes(0.15, 0.166, 0.18, 0.2, 0.25)
    self.dust:setSizeVariation(0.61980831623077)
    self.dust:setSpeed(3.4500708580017, 19.618450164795)
    self.dust:setSpin(0, 0.0005130753852427)
    self.dust:setSpread(0.31415927410126)
    self.dust:setTangentialAcceleration(0.10207310318947, 0)

    self.videogames = Sprite(WIDTH / 2, HEIGHT / 2, "bosses/computer/database/videogames", true)
    self.videogames:center(WIDTH / 2, HEIGHT / 2)
    self.videogames.anim:set("idle")
    self.speed = 1

    self.explosion = Video(-255, -120, "bosses/computer/explosion", false)
    self.explosion:rewind()
    self.explosion.scale:set(.4, .4)
    self.explosion:setBlend("add")
    self.explosion:setColor(150, 100, 255)
end

function Computer:done()
    Computer.super.done(self)

    -- self.darkness = self.scene:add(Rect(self.x, self.y, WIDTH, HEIGHT))
    -- self.darkness.z = -1000
    -- self.darkness:setColor(0, 0, 0)
    -- self.darkness.alpha = 0
end

function Computer:update(dt)
    Computer.super.update(self, dt)
    if self.mode == "off" then
        return
    end

    if self.explosion.visible then
        self.explosion:update(dt)
    end

    self.timer = self.timer + dt

    if self.mode == "videogames" then
        self.videogames:update(dt)
        self.speed = 4
    else
        self.speed = 1
    end

    if not self.turningOn then
        self.grid1.alpha = _.abs(_.sin(self.timer * .5))
        self.grid2.alpha = _.abs(_.sin((self.timer + 2) * .5))
        self.dust:update(dt)
    end

    self.radiusGrowSpeed = 50

    self.ringRadius1 = self.ringRadius1 + dt * self.radiusGrowSpeed * self.speed
    self.ringRadius2 = self.ringRadius2 + dt * self.radiusGrowSpeed * self.speed

    if self.ringRadius1 > 500 then
        self.ringRadius1 = 0
    end

    if self.ringRadius2 > 500 then
        self.ringRadius2 = 0
    end

    if self.mode ~= "waku" then
        if self.rgbTimerStart(dt) then
            if self.rgbTimerDirection(dt) then
                self:send("amount", _.random(.5, 1))
                self:send("dirs", unpack(_.shuffle({ 1, 0, 0, 1, -1, -1 })))
            end

            if self.rgbTimerOff(dt) then
                self:send("amount", 0)
                self.rgbTimerStart()
                self.rgbTimerOff()
            end
        end
    else
        if self.waku then
            self.waku:update(dt)
        end
    end

    if self.mode == "eye" then
        if not self.turningOn then
            if self.eyeMoveTimer(dt) then
                self:tween(self.eye, .5, { x = _.random(-10, 10), y = _.random(-10, 10) })
            end

            if self.eyeSizeTimer(dt) then
                self:tween(self, _.random(.3, .8), { eyeRadius = _.random(20, 40) })
            end

            self.innerCircleRadius = self.innerCircleRadiusDefault + _.sin(self.timer * .5) * 3
        end
        self.glowSize = _.sin(self.timer * .5) * 2
    elseif self.mode == "voice" then
        if self.voiceTimer(dt) then
            self:speak()
        end
    end
end

function Computer:drawInCamera()
    if self.mode == "off" then
        Computer.super.drawInCamera(self)
        return
    end
    if self.mode ~= "waku" then
        self:drawGrid()
    end
    love.graphics.setBackgroundColor(0, 0, 0, 0)
    if self.mode ~= "waku" then
        love.graphics.push("all")
        self.blur(function()
            love.graphics.setColor(131 / 255, 206 / 255, 250 / 255)
            love.graphics.circle("fill", WIDTH / 2, HEIGHT / 2, self.innerCircleRadius)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", WIDTH / 2, HEIGHT / 2, self.innerCircleRadius - self.glowSize - 5)
        end)
        love.graphics.pop()
        love.graphics.setBackgroundColor(0, 0, 0, 1)

        love.graphics.setColor(1, 1, 1, .4)
        love.graphics.setLineWidth(1)
        self:drawRadialLines(WIDTH / 2, HEIGHT / 2, self.innerCircleRadius + 15,
            self.innerCircleRadius + 5, 20,
            _.sin(self.timer * PI * .1) * -PI * .5)
        self:drawRadialLines(WIDTH / 2, HEIGHT / 2, self.innerCircleRadius + 15,
            self.innerCircleRadius + 10, 80,
            _.sin(self.timer * PI * .1) * -PI * .5)
        love.graphics.circle("line", WIDTH / 2, HEIGHT / 2, self.innerCircleRadius + 16)
    end

    if self.mode == "eye" then
        self:drawEye()
    elseif self.mode == "voice" then
        self:drawVoice()
    elseif self.mode == "videogames" then
        self:drawVideogames()
    elseif self.mode == "waku" then
        self.waku:draw()
    end


    love.graphics.setColor(1, 1, 1, .3)
    love.graphics.draw(self.dust, WIDTH / 2, HEIGHT - 50)
    love.graphics.setColor(1, 1, 1, 1)
    Computer.super.drawInCamera(self)
end

function Computer:drawGrid()
    local function stencilFunction()
        love.graphics.setLineWidth(math.min(50, self.ringRadius1))
        love.graphics.circle("line", WIDTH / 2, HEIGHT / 2, self.ringRadius1)
        love.graphics.setLineWidth(math.min(50, self.ringRadius2))
        love.graphics.circle("line", WIDTH / 2, HEIGHT / 2, self.ringRadius2)
    end

    love.graphics.stencil(stencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)

    self.grid1:draw()
    self.grid2:draw()
    self.hexagons:draw()

    love.graphics.setStencilTest()
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
    love.graphics.setLineWidth(1)
    self:drawRadialLines(WIDTH / 2 + self.eye.x * .5, HEIGHT / 2 + self.eye.y * .5, self.innerCircleRadius - 15,
        self.innerCircleRadius - 30, 50,
        _.sin(self.timer * PI * .25) * PI * .5)
    love.graphics.setLineWidth(1.5)
    love.graphics.setColor(r, g, b, .5)
    self:drawRadialLines(WIDTH / 2 + self.eye.x * .75, HEIGHT / 2 + self.eye.y * .75, self.innerCircleRadius - 40,
        self.innerCircleRadius - 55, 25,
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

function Computer:drawVideogames()
    self.explosion:draw()
    local function stencilFunction()
        love.graphics.circle("fill", WIDTH / 2, HEIGHT / 2, self.innerCircleRadius)
    end

    love.graphics.stencil(stencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)

    self.videogames:draw()

    love.graphics.setStencilTest()
end

function Computer:speak()
    for i, v in ipairs(self.voicePoints) do
        v.y = (HEIGHT / 2) + _.random(-20, 20) + (_.chance(20) and _.pick({ -20, 20 }) or 0)
        self:tween(v, .4, { y = HEIGHT / 2 })
    end
end

function Computer:placeHexagonOnRandomPosition(hexagon)
    local horizontal_gap = 44
    local vertical_gap = 40

    local horizontal_count = 22
    local vertical_count = 13

    local height = _.random(0, vertical_count, true)
    hexagon.offset.x = _.random(0, horizontal_count, true) * horizontal_gap
    hexagon.offset.y = height * vertical_gap

    if height % 2 == 1 then
        hexagon.offset.x = hexagon.offset.x + horizontal_gap / 2
    end
end

function Computer:turnOn()
    self:event(function()
        self:tween(self.scene.darkness, 3, { alpha = 0 })
        self.scene:rumble(.2, 3)
        self.coil.wait(3)
        self.turningOn = true
        self.mode = "eye"
        self.grid1.alpha = 0
        self.grid2.alpha = 0
        self.innerCircleRadius = 0
        self:tween(self, 2, { innerCircleRadius = self.innerCircleRadiusDefault })
        self:tween(self.grid1, 1, { alpha = 1 })
        self:tween(self.grid2, 1, { alpha = 1 })
        self.eyeRadius = 0
        self.coil.wait(2)
        self:tween(self, 1, { eyeRadius = 30 })
        self.coil.wait(1)
        self.turningOn = false
    end, nil, 1)
end

function Computer:pickRandomVideogame()
    self.mode = "videogames"
    self.videogames.anim:set("idle")
    self.scene.music:play("computer/game", 0, true):setLooping(false)

    self:delay(5.37, function()
        self.explosion:play()
        self.explosion:getVideo():seek(1)
        self:tween(self.explosion, .5, { alpha = 0 }):delay(.5)
    end)

    self:delay(5.37, function()
        self.videogames.anim:set("spacer_racer")
        self.videogames.scale:set(.8, .8)
        self:tween(self.videogames.scale, .25, { x = 1, y = 1 }):ease("quadout")
    end)

    self:delay(9, function()
        self.scene.music:play("computer/neutral", 2)
    end)
end

function Computer:startWaku()
    self.mode = "waku"
    self.waku = Waku(self)
    self:send("amount", 0)

    self.scene:findEntitiesOfType(FloorButton):foreach(function(e)
        e.onOverlap = function(fb, i)
            if FloorButton.onOverlap(fb, i) ~= false then
                if self.waku then
                    if fb.on then
                        self.waku:onFloorButtonPress(fb, i.e)
                    end
                end
            end
        end
    end)

    local floorButton = self.scene:findEntityWithTag("FloorButton")

    local button = self.scene:findEntityOfType(Button)
    button.triggerConnections = function()
        if self.waku then
            self.waku:onButtonPress()
        end
    end
end

function Computer:onCompletingWaku()
    if self.scene.inWakuMinigame then
        self.scene:toMainMenu()
        return
    end

    self:tween(self.waku, 1, { alpha = 0 })
        :oncomplete(function()
            self.mode = "eye"
            self.waku = nil
            self.scene:startCutscene("computer3_post_waku")
        end)
end

return Computer
