local Sprite = require "base.sprite"

local Rail = Sprite:extend("Rail")

function Rail:new(...)
    Rail.super.new(self, ...)
    self:setImage("tilesets/rail")
    self.image:setWrap("repeat", "repeat")

    self.path = { { x = 0, y = 0 } }
    self.z = 10
end

function Rail:done()
    -- table.insert(self.path, 1, { x = self.x, y = self.y })
    -- local path = self:getNormalizedPath()
    -- path = self:smoothOutPath(path, .1)
    -- local vertices = self:getVertices(path)

    -- self.smoothPath = path

    -- self.mesh = love.graphics.newMesh(vertices, "strip", "static")
    -- self.mesh:setTexture(self.image)
end

function Rail:update(dt)
    Rail.super.update(self, dt)
end

function Rail:draw()
    if self.mesh then
        love.graphics.draw(self.mesh, self.x, self.y)
    end
end

function Rail:getPath()
    return self.path
end

function Rail:buildStraight(distance)
    local last = self.path[#self.path]
    local x = last.x + distance
    local y = last.y

    table.insert(self.path, { x = x, y = y })
end

function Rail:buildCurveUp(distance, height)
    local last = self.path[#self.path]
    local endX = last.x + distance
    local endY = last.y - height

    -- Create the control points
    local controlPoints = {
        last.x, last.y,                                  -- Start point
        last.x + distance * 0.2, last.y - height * 0.04, -- Control point 1
        last.x + distance * 0.25, last.y - height * 0.1, -- Control point 1
        last.x + distance * 0.75, last.y - height * 0.9, -- Control point 2
        last.x + distance * 0.8, last.y - height * 0.96, -- Control point 1
        endX, endY                                       -- End point
    }

    local curve = love.math.newBezierCurve(controlPoints)

    -- Append the points from the curve to the path
    for t = 0, 1, 0.05 do
        local x, y = curve:evaluate(t)
        table.insert(self.path, { x = x, y = y })
    end
end

function Rail:buildCurveDown(distance, height)
    local last = self.path[#self.path]
    local endX = last.x + distance
    local endY = last.y + height

    -- Create the control points
    local controlPoints = {
        last.x, last.y,                                  -- Start point
        last.x + distance * 0.25, last.y + height * 0.1, -- Control point 1
        last.x + distance * 0.75, last.y + height * 0.9, -- Control point 2
        endX, endY                                       -- End point
    }

    local curve = love.math.newBezierCurve(controlPoints)

    -- Append the points from the curve to the path
    for t = 0, 1, 0.05 do
        local x, y = curve:evaluate(t)
        table.insert(self.path, { x = x, y = y })
    end
end

function Rail:buildLooping(radius, resolution)
    local last = self.path[#self.path]
    local controlDistance = radius * 4 * (_.sqrt(2) - 1) / 3

    -- Adjusted control points for the inward loop
    local controlPoints = {
        -- First quarter loop (upwards)
        last.x, last.y,
        last.x + controlDistance, last.y,
        last.x + radius, last.y - radius + controlDistance,
        last.x + radius, last.y - radius,
        -- Second quarter loop (to the left)
        last.x + radius, last.y - radius,
        last.x + radius, last.y - radius - controlDistance,
        last.x + radius - controlDistance, last.y - 2 * radius,
        last.x, last.y - 2 * radius,
        -- Third quarter loop (downwards)
        last.x, last.y - 2 * radius,
        last.x - controlDistance, last.y - 2 * radius,
        last.x - radius, last.y - radius - controlDistance,
        last.x - radius, last.y - radius,
        -- Fourth quarter loop (to the right)
        last.x - radius, last.y - radius,
        last.x - radius, last.y - radius + controlDistance,
        last.x - radius + controlDistance, last.y,
        last.x, last.y
    }

    local curve = love.math.newBezierCurve(controlPoints)
    local resolution = resolution or 50

    -- Append the points from the curve to the path
    for t = 0, 1, 1 / resolution do
        local x, y = curve:evaluate(t)
        table.insert(self.path, { x = x, y = y })
    end
end

function Rail:buildFinish()
    self:fixPath()
    -- self.path = self:smoothOutPath(self.path, .5)
    local vertices = self:getVertices(self.path)
    self.mesh = love.graphics.newMesh(vertices, "strip", "static")
    self.mesh:setTexture(self.image)
end

function Rail:getVertices(path)
    local vertices = {}
    local half_width = self.height / 2

    for i = 1, #path - 1 do
        local start = path[i]
        local finish = path[i + 1]

        -- Calculate the normalized direction vector
        local dx = finish.x - start.x
        local dy = finish.y - start.y
        local length = math.sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length

        -- Calculate normals (perpendiculars)
        local nx = -dy
        local ny = dx

        -- Calculate offset points for both segments
        local x1Top = start.x + nx * half_width
        local y1Top = start.y + ny * half_width
        local x1Bot = start.x - nx * half_width
        local y1Bot = start.y - ny * half_width

        local x2Top = finish.x + nx * half_width
        local y2Top = finish.y + ny * half_width
        local x2Bot = finish.x - nx * half_width
        local y2Bot = finish.y - ny * half_width

        -- Insert vertices with position and UV coordinates
        table.insert(vertices, { x1Top, y1Top, 0, 1 }) -- Top-left of the segment (Bottom of texture)
        table.insert(vertices, { x1Bot, y1Bot, 0, 0 }) -- Bottom-left of the segment (Top of texture)
        table.insert(vertices, { x2Top, y2Top, 1, 1 }) -- Top-right of the segment (Bottom of texture)
        table.insert(vertices, { x2Bot, y2Bot, 1, 0 }) -- Bottom-right of the segment (Top of texture)
    end

    return vertices
end

function Rail:fixPath()
    for i, v in _.ripairs(self.path) do
        if i == 1 then break end
        local prev = self.path[i - 1]
        if v.x == prev.x and v.y == prev.y then
            table.remove(self.path, i)
        end
    end
end

function Rail:smoothOutPath(points, t)
    if #points < 4 then
        return {} -- Cannot smooth with less than 4 points
    end

    local function catmullRom(p0, p1, p2, p3, t)
        local t2 = t * t
        local t3 = t2 * t

        local f1 = -0.5 * t3 + t2 - 0.5 * t
        local f2 = 1.5 * t3 - 2.5 * t2 + 1
        local f3 = -1.5 * t3 + 2 * t2 + 0.5 * t
        local f4 = 0.5 * t3 - 0.5 * t2

        local x = p0.x * f1 + p1.x * f2 + p2.x * f3 + p3.x * f4
        local y = p0.y * f1 + p1.y * f2 + p2.y * f3 + p3.y * f4

        return { x = x, y = y }
    end

    local smoothed = {}

    -- Append the first point
    table.insert(smoothed, points[1])

    for i = 1, #points - 3 do
        local p0, p1, p2, p3 = points[i], points[i + 1], points[i + 2], points[i + 3]

        -- Add the original point
        table.insert(smoothed, p1)

        -- Insert interpolated points
        for j = t, 1 - t, t do
            local point = catmullRom(p0, p1, p2, p3, j)
            table.insert(smoothed, point)
        end
    end

    -- Append the last two points to ensure the path completes
    table.insert(smoothed, points[#points - 1])
    table.insert(smoothed, points[#points])

    return smoothed
end

function Rail:endX()
    return self.x + self.path[#self.path].x
end

function Rail:endY()
    return self.y + self.path[#self.path].y
end

function Rail:endCoordinates()
    return self.x + self.path[#self.path].x, self.y + self.path[#self.path].y
end

function Rail:findYOnPosition(cx)
    local path = self.path

    for i = 1, #path - 1 do
        local start = path[i]
        local finish = path[i + 1]

        -- If cx is between the x values of this segment
        if cx >= self.x + start.x and cx <= self.x + finish.x then
            -- Calculate the ratio of how far cx is between start and finish
            local t = (cx - (self.x + start.x)) / (finish.x - start.x)

            -- Linearly interpolate the y value based on t
            local interpolatedY = start.y + t * (finish.y - start.y)

            return self.y + interpolatedY, i
        end
    end
end

return Rail
