local Class = require "base.class"

local Canvas = Class:extend()

function Canvas:new(width, height)
    Canvas.super.new(self)
    self.canvas = love.graphics.newCanvas(width, height)
    self.canvas:setFilter("linear", "linear")
    self.width = width
    self.height = height
    self.windowWidth = width
    self.windowHeight = height
    self.scale = 1
    self.offset = {
        x = 0,
        y = 0
    }
end

function Canvas:onWindowResize(w, h)
    self.windowWidth = w
    self.windowHeight = h
    local factor_x = w / self.width
    local factor_y = h / self.height
    self.scale = math.min(factor_x, factor_y)
    self.offset.x = factor_x > factor_y and (w - self.width * self.scale) / 2 or 0
    self.offset.y = factor_y > factor_x and (h - self.height * self.scale) / 2 or 0
end

function Canvas:clear()
    love.graphics.push("all")
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.pop()
end

function Canvas:draw(f)
    love.graphics.push("all")
    love.graphics.setCanvas(self.canvas)
    f()
    love.graphics.pop()
end

function Canvas:drawCanvas()
    love.graphics.draw(self.canvas, self.offset.x, self.offset.y, 0, self.scale, self.scale)
end

return Canvas
