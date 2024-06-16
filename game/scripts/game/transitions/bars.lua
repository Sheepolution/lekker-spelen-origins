local Rect = require "base.rect"
local Scene = require "base.scene"

local Transition = Scene:extend("Transition")

function Transition:new(...)
    Transition.super.new(self, ...)
    self.rectangles = list()
    self.visible = false
    local count = 250
    for i = 0, count - 1 do
        local rect = self.rectangles:add(self:addOverlay(Rect(-WIDTH, (HEIGHT / count) * i, WIDTH, (HEIGHT / count))))
        rect:setColor(0, 0, 0)
        -- rect.alpha = .5
    end
    self:setBackgroundAlpha(0)
end

function Transition:update(dt)
    Transition.super.update(self, dt)
end

function Transition:draw()
    if self.visible then
        Transition.super.draw(self)
    end
end

function Transition:start(fromLeft, map)
    self.inProgress = true
    self.visible = true
    local speed = .3
    local delay_short = .1

    if fromLeft then
        for i, v in ipairs(self.rectangles) do
            v.x = -WIDTH
            self:tween(v, _.random(speed), { x = 0 }):delay(_.random(delay_short))
        end
    else
        for i, v in ipairs(self.rectangles) do
            v.x = WIDTH
            self:tween(v, _.random(speed), { x = 0 }):delay(_.random(delay_short))
        end
    end

    self:delay(speed + delay_short + .8, function()
        local cb = map:getActivateWaitCallback()
        if cb then
            self:cb(cb)
        end
    end)
end

function Transition:finish(fromLeft, callback)
    local speed = .3
    if fromLeft then
        for i, v in ipairs(self.rectangles) do
            self:tween(v, _.random(speed), { x = WIDTH })
        end
    else
        for i, v in ipairs(self.rectangles) do
            self:tween(v, _.random(speed), { x = -WIDTH })
        end
    end

    self:delay(speed, function()
        if callback then callback() end
        self.inProgress = false
        self.visible = false
    end)
end

function Transition:isInProgress()
    return self.inProgress
end

return Transition
