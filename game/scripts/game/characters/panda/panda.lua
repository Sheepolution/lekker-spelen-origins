local Dancer = require("dancer", ...)

local Panda = Dancer:extend("Panda")

function Panda:new(...)
    Panda.super.new(self, ...)
    self:setImage("bosses/panda/panda", true)
    self:centerX(WIDTH / 2 + 3)
    self.y = 250
end

function Panda:update(dt)
    Panda.super.update(self, dt)
end

return Panda
