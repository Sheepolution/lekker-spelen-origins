local Dancer = require("dancer", ...)

local Fish = Dancer:extend("Fish")

function Fish:new(...)
    Fish.super.new(self, ...)
    self:setImage("bosses/panda/fish", true)
    self.x = 640
    self.y = 264
    self.anim:set("right")
end

function Fish:update(dt)
    Fish.super.update(self, dt)
end

return Fish
