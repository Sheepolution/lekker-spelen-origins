local Sprite = require "base.sprite"

local CartBackground = Sprite:extend("CartBackground")

function CartBackground:new(...)
    CartBackground.super.new(self, ...)

    self:setImage("decoration/water_background")
end

function CartBackground:update(dt)
    CartBackground.super.update(self, dt)
end

function CartBackground:draw()
    for i = 0, 100 do
        for j = 0, 20 do
            self.offset:set(i * self.width, j * self.height)
            CartBackground.super.draw(self)
        end
    end
end

return CartBackground
