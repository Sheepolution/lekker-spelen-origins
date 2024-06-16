local Dancer = require("dancer", ...)

local Frog = Dancer:extend("Frog")

function Frog:new(...)
    Frog.super.new(self, ...)
    self:setImage("bosses/panda/ant", true)
    self.x = 750
    self.y = 321
    self.anim:set("neutral")
end

function Frog:update(dt)
    Frog.super.update(self, dt)
end

return Frog
