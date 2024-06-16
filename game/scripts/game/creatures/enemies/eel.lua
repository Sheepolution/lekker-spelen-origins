local Asset = require "base.asset"
local Keycard = require "pickupables.keycard"
local Enemy = require "creatures.enemy"

local Eel = Enemy:extend("Eel")

function Eel:new(...)
    Eel.super.new(self, ...)
    self:setImage("creatures/enemies/eel", true)
    self.anim:set("idle")

    self.tail = list()
    for i = 1, 199 do
        self.tail:push({
            x = self:centerX() - i,
            y = self:centerY()
        })
    end

    local vertices = self:getVertices(self.tail)
    self.mesh = love.graphics.newMesh(vertices, "strip", "static")
    self.mesh:setTexture(Asset.image("creatures/enemies/eel_tail"))

    self.autoFlip.x = false

    self.currentPathPosition = 1

    self.updateTailTimer = step.every(.02)
    self.nextPointDelay = step.once(8)

    self.speed = 100

    self.swimming = false
    self.solid = 0

    self.hurtsPlayer = true
    self:addHitbox(20, 0, 80, 70)
end

function Eel:done()
    Eel.super.done(self)

    if self.cardColor then
        self.keycard = Keycard(self.x, self.y)
        self.keycard.colorType = self.cardColor
        self.mapLevel:add(self.keycard)
    end
end

function Eel:update(dt)
    if self.swimming then
        local point = self.path[self.currentPathPosition]
        self:rotateTowards(point, dt * .5)
        self:moveToAngle()

        if _.distance(self:centerX(), self:centerY(), point.x, point.y) < 50 or self.nextPointDelay(dt) then
            self.currentPathPosition = _.mod(self.currentPathPosition + 1, #self.path)
            self.nextPointDelay()
        end
    end

    Eel.super.update(self, dt)

    if self.swimming then
        self:updateTail(dt)
    end

    local players = self.scene:getPlayers()

    for i, player in ipairs(players) do
        if self:getDistanceX(player) < 250 then
            if self:getDistanceY(player) < 100 then
                if not self.goingOut then
                    self.goingOut = true
                    self:tween(.5, { x = self.x + 90 })
                        :ease("quintin")

                    self:delay(.3, function() self.anim:set("open") end)
                        :after(.6, function()
                            self.anim:set("close")
                            for j = 1, 10 do
                                self:emit("bubble", 15, 0, 20)
                            end
                        end)

                    if self.path and #self.path > 0 then
                        self:delay(1.5, function()
                            self.swimming = true
                        end)
                    else
                        self:tween(1, { x = self.x })
                            :ease("quadinout")
                            :delay(3)
                            :wait(2, function() self.goingOut = false end)
                    end
                end
            end
        end
    end
end

function Eel:draw()
    if self.mesh then
        love.graphics.draw(self.mesh)
    end

    Eel.super.draw(self)

    local line = {}
    for i, v in ipairs(self.tail) do
        table.insert(line, v.x)
        table.insert(line, v.y)
    end

    -- love.graphics.line(line)

    -- for i, v in ipairs(self.path) do
    --     -- Draw circles
    --     love.graphics.circle("fill", v.x, v.y, 5)
    -- end
end

function Eel:updateTail(dt)
    if not self.updateTailTimer(dt) then
        return
    end
    local opposite_angle = self.angle + math.pi
    local x, y = self:getRelativeAnglePosition(opposite_angle, self.width * .45)
    if _.distance(x, y, self.tail[1].x, self.tail[1].y) > 1 then
        self.tail:unshift({
            x = x,
            y = y
        })

        self.tail:pop()
    end

    local vertices = self:getVertices(self.tail)
    self.mesh:setVertices(vertices)

    if self.keycard and not self.keycard.pickedUp then
        local part = self.tail:last()
        self.keycard:center(part.x, part.y)
    end
end

function Eel:getVertices(path)
    local vertices = {}
    local half_width = 42 / 2

    for i = 1, #path - 30 do
        local start = path[i]
        local finish = path[i + 1]
        self:createVerticies(vertices, half_width, start, finish)
    end

    self:createVerticies(vertices, 0, path[#path - 1], path[#path])

    return vertices
end

function Eel:createVerticies(vertices, half_width, start, finish)
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

return Eel
