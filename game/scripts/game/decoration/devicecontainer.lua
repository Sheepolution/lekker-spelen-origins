local Sprite = require "base.sprite"

local DeviceContainer = Sprite:extend("DeviceContainer")

local red_color = { 178 / 255, 1, 1 }
local white_color = { 1, 1, 1 }
local base_size = 12
local offset_x = 18
local time_multiplier = 1.3

function DeviceContainer:new(...)
    DeviceContainer.super.new(self, ...)
    self:setImage("decoration/device_container", true)
    self.timer = 0
end

function DeviceContainer:done()
    self.lightSource = self.scene:addLightSource(self, 60, 90)
end

function DeviceContainer:update(dt)
    self.timer = self.timer + dt
    if self.holdingDevices then
        local sizeVariation = _.sin(self.timer * time_multiplier)
        self.deviceLeft.size = base_size + sizeVariation
        self.deviceRight.size = base_size + sizeVariation + 2
    end
    DeviceContainer.super.update(self, dt)
end

function DeviceContainer:drawDevice(cx, cy, device, offset)
    love.graphics.setColor(red_color)
    self:drawPolygonShape(cx, cy, 3, device.size * 0.34, -self.timer * 2 + offset)
    love.graphics.setColor(white_color)
    self:drawPolygonShape(cx, cy, 4, device.size * 0.583, self.timer * 1.5 + offset)
    love.graphics.setColor(red_color)
    self:drawPolygonShape(cx, cy, 5, device.size * 0.84, -self.timer * 3 + offset)
    love.graphics.setColor(white_color)
    love.graphics.circle('line', cx, cy, device.size)
end

function DeviceContainer:draw()
    if self.holdingDevices then
        local distance = 15 + _.sin(self.timer) * 3
        local yOffset = 2

        local cx, cy = self.deviceLeft.x, distance * _.sin(self.timer) + yOffset + self.deviceLeft.y
        self:drawDevice(cx, cy, self.deviceLeft, 0)

        cx, cy = self.deviceRight.x, distance * _.sin(self.timer + 2) + yOffset + self.deviceRight.y
        self:drawDevice(cx, cy, self.deviceRight, 1)
    end

    DeviceContainer.super.draw(self)
end

function DeviceContainer:addDevices()
    local x, y = self:center()
    self.deviceLeft = { x = x - offset_x, y = y, size = base_size }
    self.deviceRight = { x = x + offset_x, y = y, size = base_size }
    self.holdingDevices = true
end

function DeviceContainer:drawPolygonShape(cx, cy, edges, size, angle)
    if edges < 3 then
        return -- Need at least 3 edges to draw a polygon
    end

    local angleStep = 2 * math.pi / edges

    -- Begin drawing the shape
    love.graphics.push() -- Save the current state
    love.graphics.translate(cx, cy)
    love.graphics.rotate(angle)

    -- Define the polygon's points
    local points = {}
    for i = 0, edges - 1 do
        local x = size * math.cos(i * angleStep)
        local y = size * math.sin(i * angleStep)
        table.insert(points, x)
        table.insert(points, y)
    end

    love.graphics.polygon('line', points)

    love.graphics.pop() -- Restore the previous state
end

function DeviceContainer:giveDevicesToPlayers()
    self:delay(.5, function()
        self.holdingDevices = false
    end)
    local tx, ty = self.scene.timon:center()
    self:tween(self.deviceLeft, 0.5, { x = tx, y = ty, size = 0 })

    local px, py = self.scene.peter:center()
    self:tween(self.deviceRight, 0.5, { x = px, y = py, size = 0 })
end

return DeviceContainer
