local Interactable = require("interactable", ...)
local Entity = require "base.entity"

local LineDrawer = Entity:extend("LineDrawer")

function LineDrawer:new(...)
    LineDrawer.super.new(self, ...)
    self.interactables = list()
end

function LineDrawer:clear()
    self.interactables:clear()
end

local function drawDashedLine(x1, y1, x2, y2, dashLength, gapLength, offset)
    -- If x1 > x2, swap all values
    local reverse = false
    if x1 > x2 or (x1 == x2 and y1 > y2) then
        reverse = true
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end

    -- Calculate distance between two points
    local dx = x2 - x1
    local dy = y2 - y1
    local dist = math.sqrt(dx * dx + dy * dy)

    -- Normalize
    dx = dx / dist
    dy = dy / dist

    local dashCount = math.floor((dist + offset) / (dashLength + gapLength))
    local remainder = (dist + offset) % (dashLength + gapLength)
    local lastDashLength = remainder - gapLength
    if lastDashLength < 0 then lastDashLength = 0 end

    for i = 0, dashCount do
        local dashStart = i * (dashLength + gapLength) - offset
        local dashEnd = dashStart + dashLength

        -- Adjust for first and last dashes
        if i == 0 then
            dashStart = 0
        elseif i == dashCount then
            dashEnd = dashStart + lastDashLength
        end

        local startX = x1 + dashStart * dx
        local startY = y1 + dashStart * dy
        local endX = x1 + dashEnd * dx
        local endY = y1 + dashEnd * dy

        if reverse then
            local tempX = x1 + (dist - dashEnd) * dx
            local tempY = y1 + (dist - dashEnd) * dy
            endX = x1 + (dist - dashStart) * dx
            endY = y1 + (dist - dashStart) * dy
            startX = tempX
            startY = tempY
        end

        if endX >= x1 and startX <= x2 then
            love.graphics.line(startX, startY, endX, endY)
        end
    end
end

function LineDrawer:draw()
    for i, v in ipairs(self.interactables) do
        local player, distance = self.scene:findNearestPlayer(v)
        if not player or not distance then return end
        if distance < 150 then
            for j, w in ipairs(v.connectionEntities) do
                local x1, y1 = v.linePosition:get()
                local x2, y2 = w.linePosition:get()
                love.graphics.setLineWidth(1)

                local speed = -30
                local dash = 10
                local gap = 10
                local offset = (self.lifespan * speed) % (dash + gap)

                local alpha = (1 - (distance - 50) / 100) * .1

                love.graphics.setColor(1, 1, 1, alpha)
                drawDashedLine(x1, y1, x2, y2, dash, gap, offset, 1)
            end
        end
    end
end

function LineDrawer:addInteractable(interactable)
    if not interactable.connectionEntities then
        warning("Interactable has no connectionEntities")
    end

    self.interactables:add(interactable)
end

return LineDrawer
