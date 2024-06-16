local Sprite = require "base.sprite"

local WaterBackground = Sprite:extend("WaterBackground")

function WaterBackground:new(...)
    WaterBackground.super.new(self, ...)

    self:setImage("decoration/water_background")
    self.z = ZMAP.Background + 1
end

function WaterBackground:update(dt)
    WaterBackground.super.update(self, dt)
end

function WaterBackground:draw()
    for i = 0, 20 do
        for j = 0, 20 do
            self.offset:set(i * self.width, j * self.height)
            WaterBackground.super.draw(self)
        end
    end
end

return WaterBackground
