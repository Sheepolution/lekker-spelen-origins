local Circle = require "base.circle"

local Smoke = Circle:extend("Smoke")

function Smoke:new(x, y, angle)
    Smoke.super.new(self, x, y)
    self.radius = 5
    self.mode = "line"
    self.angle = angle
    self.movementSpeed = 260
    self.growingSpeed = 50
    self.maxRadius = 300
    self.time = 0
    self.thickness = 1
    self:setColor(200, 200, 200, .5)
end

function Smoke:update(dt)
    self.radius = self.radius + self.growingSpeed * dt

    if self.radius > self.maxRadius then
        self.radius = self.maxRadius
    end

    local cos, sin = _.cos(self.angle), _.sin(self.angle)
    self.x = self.x + cos * self.movementSpeed * dt
    self.y = self.y + sin * self.movementSpeed * dt

    self.time = self.time + dt * 4

    local players = self.scene:getPlayers()
    for i, v in ipairs(players) do
        if _.distance(self.x, self.y, v:center()) < self.radius + v.height * .3 then
            v:hurt()
        end
    end
end

function Smoke:draw(mode, segments)
    love.graphics.setLineWidth(self.thickness)
    local r = self.radius
    self:setColor(200, 200, 200, .3)
    love.graphics.setColor(self._color[1], self._color[2], self._color[3], self.alpha)
    self:drawWavyCircle(1)
    self:setColor(180, 180, 180, .5)
    love.graphics.setColor(self._color[1], self._color[2], self._color[3], self.alpha)
    self.radius = self.radius - 1
    self:drawWavyCircle(-1.7)
    self.radius = r
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setLineWidth(2)
end

function Smoke:drawWavyCircle(dir)
    local segments = 200 -- Number of segments to draw the circle
    local deltaTheta = 2 * math.pi / segments
    local r = self.radius
    local A = r * 0.03
    local B = dir == 1 and 7 or 8
    local C = self.time * dir

    local segmentList = {}

    for i = 0, segments - 1 do
        local theta1 = i * deltaTheta
        local theta2 = (i + 1) * deltaTheta

        local r1 = r + A * math.sin(B * theta1 + C)
        local r2 = r + A * math.sin(B * theta2 + C)

        local x1 = self.x + r1 * math.cos(theta1)
        local y1 = self.y + r1 * math.sin(theta1)

        local x2 = self.x + r2 * math.cos(theta2)
        local y2 = self.y + r2 * math.sin(theta2)

        if i == 0 then
            table.insert(segmentList, x1)
            table.insert(segmentList, y1)
        end

        table.insert(segmentList, x2)
        table.insert(segmentList, y2)
    end
    love.graphics.line(segmentList)
end

return Smoke
