local Sprite = require "base.sprite"
local Entity = require "base.entity"
local Clone = require "objects.clone"
local Player = require "characters.players.player"

local Sawblade = Entity:extend("Sawblade")

Sawblade:addExclusiveOverlap(Player, Clone)

function Sawblade:new(...)
    Sawblade.super.new(self, ...)
    self:setImage("hazards/sawblade", true)
    self.innerPart = Sprite(0, 0, "hazards/sawblade_inner", true)
    self.hurtsPlayer = true
    self.teleportsPlayer = false
    self.rotation = 25 * _.scoin()
    self.solid = 0
    self.circlePosition = 0

    self:addHitbox(self.width * .8, self.height * .8)

    self.anim:set("default")
    self.hitsPlayerSFX = "hazards/sawblade1"
    self.z = -5
end

function Sawblade:done()
    Sawblade.super.done(self)
    if self.path and #self.path > 0 then
        table.insert(self.path, { x = self.x - 8, y = self.y - 8 })
        for i, v in ipairs(self.path) do
            v.x = v.x - self.origin.x
            v.y = v.y - self.origin.y
        end

        self.x = self.path[#self.path].x
        self.y = self.path[#self.path].y

        local tween
        local current = 1
        function tween()
            local next_point = self.path[_.mod(current, #self.path)]
            local distance = _.distance(self.x, self.y, next_point.x, next_point.y)
            local duration = distance / self.speed

            self:tween(duration, { x = next_point.x, y = next_point.y }):oncomplete(tween):ease("linear")
            current = _.mod(current + 1, #self.path)
        end

        tween()
        self.pathForDrawing = {}
        for i, v in ipairs(self.path) do
            table.insert(self.pathForDrawing, v.x + self.origin.x)
            table.insert(self.pathForDrawing, v.y + self.origin.y)
        end
        table.insert(self.pathForDrawing, self.path[1].x + self.origin.x)
        table.insert(self.pathForDrawing, self.path[1].y + self.origin.y)
    end

    if self.radius then
        local distance = _.abs(self.x - self.radius.x)
        self.radius = distance
        self.centerPoint = {
            x = self:centerX() - self.origin.x,
            y = self:centerY() - self.origin.y
        }

        self.rotationSpeed = (self.speed / self.radius) * .5
        self.rotationDirection = self.reverse and -1 or 1
    end
end

function Sawblade:update(dt)
    Sawblade.super.update(self, dt)
    self.innerPart:update(dt)

    if self.radius then
        -- Have the sawblade rotate around a point
        self.circlePosition = self.circlePosition + dt * TAU * self.rotationSpeed * self.rotationDirection
        self:centerX(self.centerPoint.x + self.radius * _.cos(self.circlePosition))
        self:centerY(self.centerPoint.y + self.radius * _.sin(self.circlePosition))
    end
end

function Sawblade:extraOverlapCheck(e, myHitbox, theirHitbox)
    local collide = intersect.circle_aabb_overlap(vec2(self:center()), self.width * .4,
        vec2(theirHitbox.bb.x, theirHitbox.bb.y),
        vec2(theirHitbox.bb.width, theirHitbox.bb.height))

    return collide
end

function Sawblade:draw()
    if self.pathForDrawing then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.line(self.pathForDrawing)
    elseif self.radius then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("line", self.centerPoint.x, self.centerPoint.y, self.radius)
    end

    self.innerPart:drawAsChild(self)
    Sawblade.super.draw(self)
end

return Sawblade
