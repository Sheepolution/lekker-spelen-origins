local Laser = require "projectiles.laser"
local Direction = Enums.Direction
local Input = require "base.input"
local Sprite = require "base.sprite"
local Entity = require "base.entity"

local GoochemCart = Entity:extend("Cart")

function GoochemCart:new(cart)
    GoochemCart.super.new(self)
    self:setImage("creatures/enemies/goochem_cart")
    self.pathPosition = 1
    self.pathIndex = 1
    self.speed = -300
    self.solid = 0
    self.angleTo = 0
    self.onRail = true

    self.railSpeed = { x = 0, y = 0 }

    self.driving = false

    self.playerCart = cart

    self.hurtsPlayer = true
end

function GoochemCart:update(dt)
    if self.onRail and self.driving then
        self.pathPosition = self.pathPosition + self.speed * dt
        self:positionCart()
    end

    self.angle = _.rotate(self.angle, self.angleTo, dt * _.abs(self.angle - self.angleTo) * 15)

    GoochemCart.super.update(self, dt)

    if not self.onRail and self.velocity.y > 0 then
        self:findRailToLandOn()
    end

    if self.x - self.playerCart.x < 1000 then
        self.driving = true
    end
end

function GoochemCart:setPath(rail, path)
    self.rail = rail
    self.path = path
    self:positionCart()
end

function GoochemCart:positionCart()
    local start, finish = self.path[self.pathIndex], self.path[self.pathIndex + 1]
    if not finish then
        self.velocity.x = self.railSpeed.x * self.speed
        self.velocity.y = self.railSpeed.y * self.speed
        self.onRail = false
        self.gravity = 1000
        return
    end

    local dx = finish.x - start.x
    local dy = finish.y - start.y
    local length = math.sqrt(dx * dx + dy * dy)
    local nx = dx / length
    local ny = dy / length

    -- Calculate the normals (perpendiculars) for the direction vector
    local perpX = -ny
    local perpY = nx

    -- Calculate the offset for the cart's position.
    -- Adjust the multiplier (0.5 in this case) if needed.
    local offsetX = perpX * 0.5 * self.rail.width
    local offsetY = perpY * 0.5 * self.rail.height

    offsetX = offsetX - perpX * 0.5 * self.height
    offsetY = offsetY - perpY * 0.6 * self.height

    -- Now add this offset to the position of the cart
    self:centerX(self.rail.x + start.x + nx * self.pathPosition + offsetX)
    self:centerY(self.rail.y + start.y + ny * self.pathPosition + offsetY)

    self.railSpeed.x = nx
    self.railSpeed.y = ny

    if self.pathPosition >= length then
        self.pathIndex = self.pathIndex + 1
        self.pathPosition = 0
    end

    self.angleTo = math.atan2(dy, dx)
end

function GoochemCart:findRailToLandOn()
    local rails = self.scene:findEntitiesWithTag("Rail")
    rails:filterInplace(function(e) return e.x < self:right() and e.endX > self.x end)

    local cx = self:centerX()

    for i, v in ipairs(rails) do
        local y, index = v:findYOnPosition(cx)
        if y then
            if self:bottom() > y and self:top() < y then
                self.rail = v
                self.path = v:getPath()
                self.pathIndex = index
                self.pathPosition = self:getPathPositionBasedOnX(cx, index)
                self.onRail = true
                self.gravity = 0
                self:stopMoving()
                self:positionCart()
                self.angle = self.angleTo
                break
            end
        end
    end
end

return GoochemCart
