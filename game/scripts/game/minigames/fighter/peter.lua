local Fighter = require("fighter", ...)

local Peter = Fighter:extend("Peter")

function Peter:new(...)
    Peter.super.new(self, ...)
    self:setImage("minigames/fighter/peter", true)
    self.anim:set("stand")

    self.controllerId = 1
end

function Peter:update(dt)
    Peter.super.update(self, dt)
end

return Peter
