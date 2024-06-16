local HCbox = require "base.hcbox"
local Entity = require "base.entity"

local Charger = Entity:extend("Charger")

function Charger:new(...)
    Charger.super.new(self, ...)
    self:setImage("minigames/ufo/charger")
    self.ogWidth = self.width
    self.ogHeight = self.height

    self.start = { x = self.x, y = self.y }

    self.lightningTimer = step.every(1.3)
    self.lightningEffectTimer = step.every(0.1)

    self.lightning = false

    self.isDangerous = false

    self.z = -10
end

function Charger:done()
    Charger.super.done(self)
    self:clearHitboxes()

    if self.width > self.height then
        self.y = self.y + 16 - self.ogHeight / 2
        self.horizontal = true
        self.height = self.ogHeight
        self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x, self.y, self.width, self.ogHeight)

        if self.path then
            self.path = {
                { x = self.x, y = self.y },
                { x = self.x, y = self.path.y },
            }
        end
    else
        self.x = self.x + 16 - self.ogHeight / 2
        self.y = self.y + 3
        self.vertical = true
        self.width = self.ogWidth
        self.hcbox = HCbox(self, self.scene.HC, HCbox.Shape.Rectangle, self.x, self.y, self.ogWidth, self.height)

        if self.path then
            self.path = {
                { x = self.x,      y = self.y },
                { x = self.path.x, y = self.y },
            }
        end
    end

    if self.path then
        local tween
        local i = 1
        tween = function()
            local distance = _.distance(self.x, self.y, self.path[i].x, self.path[i].y)
            local duration = self.horizontal and distance / self.speed or distance / self.speed
            self:tween(self, duration, self.path[i]):ease("linear")
                :onupdate(function(dt) self.hcbox:update(dt) end)
                :oncomplete(function()
                    i = _.mod(i + 1, 2)
                    tween()
                end)
        end
        tween()
    end

    self.startsWithLightning = self.lightning
end

function Charger:update(dt)
    Charger.super.update(self, dt)

    if self.lightningTimer(dt) then
        self.lightning = not self.lightning
        self.lightningEffectTimer:finish()
        if self.lightning then
            self.lightningDelay = self:delay(.1, { isDangerous = true })
                :after(1, function()
                    self.isDangerous = false
                    self.lightningDelay = nil
                end)
        end
    end

    if self.lightning then
        if self.lightningEffectTimer(dt) or not self.lightningPointsDark then
            self.lightningPointsDark = self:getElectricPoints()
            self.lightningPointsLight = self:getElectricPoints()
        end
    end
end

function Charger:draw()
    local lineOffset = self.width - self.ogWidth
    local coordType = "x"

    if self.vertical then
        lineOffset = self.height - self.ogWidth
        coordType = "y"
        self.angle = PI / 2
    end

    self.offset[coordType] = 0
    self.flip.x = false
    Charger.super.draw(self)
    self.offset[coordType] = lineOffset
    self.flip.x = true
    Charger.super.draw(self)

    if self.lightning and self.lightningPointsDark then
        love.graphics.push("all")
        love.graphics.setLineWidth(1)
        love.graphics.setLineStyle("rough")
        love.graphics.translate(self.x - self.start.x, self.y - self.start.y)
        love.graphics.setColor(1 / 255, 99 / 255, 198 / 255, 1)
        love.graphics.line(self.lightningPointsDark)
        love.graphics.setColor(100 / 255, 165 / 255, 1, 1)
        love.graphics.line(self.lightningPointsLight)
        love.graphics.pop()
    end
end

-- Generate points for the electric field
function Charger:getElectricPoints()
    local primaryStart, primaryEnd, secondaryCenter

    if self.horizontal then
        primaryStart = self.start.x + self.ogWidth
        primaryEnd = self.start.x + self.width - self.ogWidth
        secondaryCenter = self.start.y + self.height / 2
    else
        primaryStart = self.start.y + self.ogWidth - 3
        primaryEnd = self.start.y + self.height - self.ogWidth - 3
        secondaryCenter = self.start.x + self.width / 2
    end

    local points = {}
    if self.horizontal then
        table.insert(points, primaryStart)
        table.insert(points, secondaryCenter)
    else
        table.insert(points, secondaryCenter)
        table.insert(points, primaryStart)
    end

    local step = 4
    local stepY = 3

    local primary = primaryStart

    while primary < primaryEnd do
        local nextPrimary = primary + step
        local nextSecondary = secondaryCenter + _.random(-stepY, stepY)

        if nextPrimary >= primaryEnd then
            if self.horizontal then
                table.insert(points, primaryEnd)
                table.insert(points, secondaryCenter)
            else
                table.insert(points, secondaryCenter)
                table.insert(points, primaryEnd)
            end
            break
        end

        if self.horizontal then
            table.insert(points, nextPrimary)
            table.insert(points, nextSecondary)
        else
            table.insert(points, nextSecondary)
            table.insert(points, nextPrimary)
        end

        primary = nextPrimary
    end

    return points
end

function Charger:onRaceStart()
    if self.lightningDelay then
        self.lightningDelay:stop()
        self.lightningDelay = nil
    end

    self.lightning = self.startsWithLightning
    self.isDangerous = false
    self.lightningTimer()
end

return Charger
