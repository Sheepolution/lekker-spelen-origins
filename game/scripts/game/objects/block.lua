local SFX = require "base.sfx"
local Entity = require "base.entity"

local Block = Entity:extend("Block")

Block.SFX = {
    land = SFX("sfx/objects/block_land"),
    push = SFX("sfx/objects/block_push"),
}

function Block:new(...)
    Block.super.new(self, ...)
    self:setImage("objects/block")
    self.offset.y = 8
    self.solid = 2
    self.separatePriority:set(50, 50)
    self.pushable = true
    self.floorButtonPresser = true

    self.teleportsPlayer = true
    self.hurtsSide = "bottom"

    self:addHitbox(0, 8, self.width - 2, self.height - 16, nil, true)

    self.lines = self:getTeleportationLines(self.imageData)
    for i, v in ipairs(self.lines) do
        local y1_start = v[2]
        local y2_start = v[4]
        v[2] = self.height / 2
        v[4] = self.height / 2
        self:tween(v, _.random(.1, .3), { [2] = y1_start, [4] = y2_start })
    end

    self.alpha = 0
    self:tween(.3, { alpha = 1 }):delay(.1)
    self:delay(.4, self.F({ useGravity = true, gravity = 2000 }))

    self.pushSoundInterval = step.every(.5)
    self.pushSoundInterval:finish()

    self.pushSoundDelay = step.once(.2)
end

function Block:update(dt)
    self.hurtsPlayer = self.velocity.y > 0
    if self.last.y == self.y and self.x ~= self.last.x then
        self.pushSoundDelay()
        if self.pushSoundInterval(dt) then
            self.SFX.push:play("reverb")
        end
    else
        if self.pushSoundDelay(dt) then
            self.pushSoundInterval:finish()
        end
    end

    Block.super.update(self, dt)
end

function Block:draw()
    Block.super.draw(self)
    love.graphics.push()
    love.graphics.translate(self.x, self.y + self.offset.y)
    love.graphics.setColor(178 / 255, 1, 1, 1 - self.alpha)
    for i, v in ipairs(self.lines) do
        love.graphics.line(v)
    end
    love.graphics.pop()
end

function Block:onSeparate(e, i)
    local velocity = self.velocity.y
    Block.super.onSeparate(self, e, i)
    local player, distance = self.scene:findNearestPlayer(self)
    if velocity > 200 and i.myBottom and distance < 1000 then
        self.SFX.land:play("reverb")
    end
end

function Block:kill()
    Block.super.kill(self)
    self:stopMoving()
    self.useGravity = false
    self:delay(.1, self.F({ useGravity = false, gravity = 0 }))
    self:tween(.3, { alpha = 0 }):oncomplete(function()
        self:destroy()
    end)

    self.lines = self:getTeleportationLines(self.imageData)
    for i, v in ipairs(self.lines) do
        self:tween(v, _.random(.1, .3), { [2] = self.height / 2, [4] = self.height / 2 })
    end

    self:tween(.1, { alpha = 0 }):delay(.1):oncomplete(self.F:destroy())
end

function Block:getTeleportationLines(imageData)
    local frame = imageData

    local y_min_max = {}

    frame:mapPixel(function(x, y, r, g, b, a)
        if a > 0 and x % 4 == 0 then -- Replace this condition with your own
            if not y_min_max[x] then
                y_min_max[x] = { min = y, max = y }
            else
                if y < y_min_max[x].min then y_min_max[x].min = y end
                if y > y_min_max[x].max then y_min_max[x].max = y end
            end
        end

        return r, g, b, a
    end)

    local lines = {}
    for x, minMax in pairs(y_min_max) do
        table.insert(lines, { x, minMax.min, x, minMax.max })
    end

    return lines
end

return Block
