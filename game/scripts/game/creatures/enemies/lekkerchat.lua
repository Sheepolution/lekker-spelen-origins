local Enemy = require "creatures.enemy"

local LekkerChat = Enemy:extend("LekkerChat")

function LekkerChat:new(...)
    LekkerChat.super.new(self, ...)
    self:setImage("creatures/enemies/lekkerchat", true)
    self.hurtsPlayer = true
    self.solid = 0

    self:addHitbox(self.width * .8, self.height * .8)
end

function LekkerChat:done()
    LekkerChat.super.done(self)
    if self.path and #self.path > 0 then
        table.insert(self.path, { x = self.x, y = self.y })
        for i, v in ipairs(self.path) do
            v.x = v.x - self.origin.x / 2
            v.y = v.y - self.origin.y * .75
        end
        local tween
        local current = 1
        function tween()
            local next_point = self.path[_.mod(current, #self.path)]
            local distance = _.distance(self.x, self.y, next_point.x, next_point.y)
            local duration = distance / self.speed

            self.moveTween = self:tween(duration, { x = next_point.x, y = next_point.y }):oncomplete(tween):ease(
                "quintinout")
            current = _.mod(current + 1, #self.path)
        end

        tween()
    end

    if self.radius then
        local distance = _.abs(self.x - self.radius.x)
        self.radius = distance
        self.centerPoint = {
            x = self:centerX() - self.origin.x,
            y = self:centerY() - self.origin.y
        }

        self.circlePosition = 0
        self.rotationSpeed = (self.speed / self.radius) * .5
        self.rotationDirection = self.reverse and -1 or 1
    end
end

function LekkerChat:update(dt)
    LekkerChat.super.update(self, dt)

    if self.radius then
        if not self.died then
            -- Have lekkerChat rotate around a point
            self.circlePosition = self.circlePosition + dt * TAU * self.rotationSpeed * self.rotationDirection
            self:centerX(self.centerPoint.x + self.radius * _.cos(self.circlePosition))
            self:centerY(self.centerPoint.y + self.radius * _.sin(self.circlePosition))
        end
    end

    if self.x ~= self.last.x then
        self.flip.x = self.x < self.last.x
    end
end

function LekkerChat:kill()
    LekkerChat.super.kill(self)
    if self.moveTween then
        self.moveTween:stop()
    end
    self.hurtsPlayer = false
end

return LekkerChat
