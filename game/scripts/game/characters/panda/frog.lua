local Dancer = require("dancer", ...)

local Frog = Dancer:extend("Frog")

function Frog:new(...)
    Frog.super.new(self, ...)
    self:setImage("bosses/panda/frog", true)
    self.x = 168
    self.y = 275
    self.anim:set("left")
end

function Frog:update(dt)
    Frog.super.update(self, dt)
end

return Frog
