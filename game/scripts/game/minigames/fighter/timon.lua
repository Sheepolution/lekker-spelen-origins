local Fighter = require("fighter", ...)

local Timon = Fighter:extend("Timon")

function Timon:new(...)
    Timon.super.new(self, ...)
    self:setImage("minigames/fighter/timon", true)
    self.anim:set("stand")

    self.controllerId = 2
end

function Timon:update(dt)
    Timon.super.update(self, dt)
end

return Timon
