local Laser = require "projectiles.laser"
local Direction = Enums.Direction
local Input = require "base.input"
local Sprite = require "base.sprite"
local Save = require "base.save"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local Cart = Entity:extend("Cart")

Cart.keys = {
    {
        left = { "a", "c2_left_left" },
        right = { "d", "c2_left_right" },
        down = { "s", "c2_left_down", "c2_leftshoulder", "c2_leftstick" },
        up = { "w", "c2_left_up" },
        standstill = { "o", "c2_rightshoulder" },
        ability = { "space", "c2_b", "c2_triggerright" },
        jump = { "c1_a" },
    },
    {
        left = { "c1_left_left" },
        right = { "c1_left_right" },
        down = { "c1_left_down", "c1_leftshoulder", "c1_leftstick" },
        up = { "c1_left_up" },
        standstill = { "c1_rightshoulder" },
        ability = { "c1_b", "c1_triggerright" },
        jump = { "z", "s", "c2_a" },
    }
}

if DEBUG then
    Cart.keys = {
        {
            left = { "a", "c2_left_left" },
            right = { "d", "c2_left_right" },
            down = { "s", "c2_left_down", "c2_leftshoulder", "c2_leftstick" },
            up = { "w", "c2_left_up" },
            standstill = { "o", "c2_rightshoulder" },
            ability = { "e", "c2_b", "c2_triggerright" },
            jump = { "up", "c1_a" },
        },
        {
            left = { "left", "c1_left_left" },
            right = { "right", "c1_left_right" },
            down = { "s", "c1_left_down", "c1_leftshoulder", "c1_leftstick" },
            up = { "up", "c1_left_up" },
            standstill = { "o", "c1_rightshoulder" },
            ability = { "e", "c1_b", "c1_triggerright" },
            jump = { "w", "c2_a" },
        }
    }
end


Cart.SFX = SFX("sfx/players/shoot_timon", 4, { pitchRange = .04 })

function Cart:new(...)
    Cart.super.new(self, ...)
    self:setImage("characters/players/konkie/cart", true)
    self.anim:set("empty")
    self.pathPosition = 1
    self.pathIndex = 1
    self.speed = 600
    self.solid = 0
    self.angleTo = 0
    self.onRail = true

    self.railSpeed = { x = 0, y = 0 }

    self.timon = Sprite(0, 0, "characters/players/konkie/timon", true)
    self.timon.anim:set("idle")
    self.timon.cartOffset = -40
    -- self.timon.origin:clone(self.origin)

    self.driving = false

    self.hasPeter = false
    self.hasTimon = false
    self.inControl = false

    self.laserShootDelay = step.after(.2)

    self.hitbox = self:addHitbox()
    self.hurtbox = self:addHitbox(self.width * .60, self.height * .50)

    self.hurtCooldown = step.during(1)

    self.health = 3
    self.autoFlip.x = false

    self.coyote = step.during(.2)
end

function Cart:update(dt)
    self.controllerId = Save:get("settings.controls.peter.player1") and 1 or 2
    self.timon:update(dt)

    if self.inControl then
        if Input:isPressed(Cart.keys[self.controllerId].jump) then
            self:jump()
        end

        if not Input:isDown(Cart.keys[self.controllerId].standstill) then
            if Input:isDown(Cart.keys[self.controllerId].left) then
                self.timon.cartOffset = self.timon.cartOffset - 200 * dt
            elseif Input:isDown(Cart.keys[self.controllerId].right) then
                self.timon.cartOffset = self.timon.cartOffset + 200 * dt
            end
        end

        self.timon.cartOffset = _.clamp(self.timon.cartOffset, -45, 20)
    end

    if self.onRail and self.driving then
        self.pathPosition = self.pathPosition + self.speed * dt
        local x = self.x
        self:positionCart()
        -- Calculate speed based on difference in x
        -- self.currentSpeed = (self.x - x) / dt
    else
        self.coyote(dt)
    end

    self.angle = _.rotate(self.angle, self.angleTo, dt * _.abs(self.angle - self.angleTo) * 15)

    Cart.super.update(self, dt)

    if not self.onRail and self.velocity.y > 0 then
        self:findRailToLandOn()
    end

    if self.inControl then
        if self.laserShootDelay(dt) then
            if Input:isDown(Cart.keys[self.controllerId].ability) then
                self:shootLaser()
            end
        end
    end

    if self.railSpeed.x * self.speed < -self.speed * .8 then
        self.timon.anim:set("sick")
    end

    self.hurtCooldown(dt)
end

function Cart:draw()
    Cart.super.draw(self)
    if self.hasTimon then
        self.timon.angle = self.angle

        -- Move left or right based on self.timon.cartOffset, using the angle.
        local dx = _.cos(self.angle) * self.timon.cartOffset
        local dy = _.sin(self.angle) * self.timon.cartOffset
        self.timon.offset.x = dx
        self.timon.offset.y = dy

        self.timon:drawAsChild(self)
    end
end

function Cart:jump()
    if not self.onRail and not self.coyote(0) then return end
    self.velocity.y = -1300
    self.gravity = 4500
    self.velocity.x = self.railSpeed.x * self.speed
    self.onRail = false
end

function Cart:setPath(rail, path)
    self.rail = rail
    self.path = path
    self.pathPosition = 120
    self:positionCart()
end

function Cart:positionCart()
    local start, finish = self.path[self.pathIndex], self.path[self.pathIndex + 1]
    if not finish then
        self.velocity.x = self.railSpeed.x * self.speed
        self.velocity.y = self.railSpeed.y * self.speed
        self.onRail = false
        self.gravity = 4500
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

function Cart:findRailToLandOn()
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
                self.coyote()
                self:stopMoving()
                self:positionCart()
                self.angle = self.angleTo
                break
            end
        end
    end
end

function Cart:getPathPositionBasedOnX(cx, i)
    local start = self.path[i]
    local finish = self.path[i + 1]

    -- Assuming segments are primarily horizontal (i.e., x-axis changes, not y).
    local dx = finish.x - start.x

    -- Calculate the relative position on the segment.
    local t = (cx - (self.rail.x + start.x)) / dx

    -- Convert the relative position (t) to an actual path position based on segment length.
    local segmentLength = math.sqrt(dx * dx + (finish.y - start.y) ^ 2)
    local pathPosition = t * segmentLength

    return pathPosition
end

function Cart:onOverlap(i)
    Cart.super.onOverlap(self, i)
    if self.capturesPlayers then
        local player
        if i.e.tag == "Peter" then
            if not self.hasPeter then
                self.hasPeter = true
                player = i.e
                self.anim:set("peter")
                if not self.hasTimon then
                    self:delay(5, function()
                        if not self.hasTimon then
                            self.scene.timon:teleport(self.x, self.y)
                            self.scene.timon:center(self.x, self.y)
                        end
                    end)
                end
            end
        elseif i.e.tag == "Timon" then
            if not self.hasTimon then
                self.hasTimon = true
                player = i.e

                if not self.hasPeter then
                    self:delay(5, function()
                        if not self.hasPeter then
                            self.scene.peter:teleport(self.x, self.y)
                            self.scene.peter:center(self.x, self.y)
                        end
                    end)
                end
            end
        end

        if player then
            i.e.inControl = false
            i.e:stopMoving()
            i.e.useGravity = false
            i.e.accel.y = 0
            i.e.visible = false
            i.e.movementDirection = nil
            if self.hasPeter and self.hasTimon then
                self.driving = true
            end
        end
    end

    if i.myHitbox == self.hurtbox and i.e.hurtsPlayer then
        self:hurt()
    end
end

function Cart:shootLaser()
    self.laserShootDelay()

    local direction = Input:isDown(self.keys[self.controllerId].left) and Direction.Left or
        (Input:isDown(self.keys[self.controllerId].right) and Direction.Right or Direction.Up)

    if Input:isDown(self.keys[self.controllerId].up) then
        if Input:isDown(self.keys[self.controllerId].left) then
            direction = Direction.LeftUp
        elseif Input:isDown(self.keys[self.controllerId].right) then
            direction = Direction.RightUp
        else
            direction = Direction.Up
        end
    elseif Input:isDown(self.keys[self.controllerId].down) then
        if Input:isDown(self.keys[self.controllerId].left) then
            direction = Direction.LeftDown
        elseif Input:isDown(self.keys[self.controllerId].right) then
            direction = Direction.RightDown
        else
            direction = Direction.Down
        end
    end

    local x, y = self:centerX(), self:centerY() - 40

    local dx = _.cos(self.angle) * self.timon.cartOffset
    local dy = _.sin(self.angle) * self.timon.cartOffset

    local laser = self.scene:add(Laser(x + dx, y + dy, direction, "Timon", self.angle))
    laser.velocity.x = laser.velocity.x + self.railSpeed.x * self.speed
    Cart.SFX:play()
end

function Cart:hurt()
    if self.hurtCooldown(0) then
        return
    end

    self.health = self.health - 1
    -- self:shake(5, .3)
    self.anim:set("heart_" .. self.health)
    if self.health <= 0 then
        self.room:die()
    end
    self.hurtCooldown()
end

return Cart
