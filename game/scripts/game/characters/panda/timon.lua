local Player = require("player", ...)

local Timon = Player:extend("Timon")

function Timon:new(...)
    Timon.super.new(self, ...)
    self:setImage("bosses/panda/timon", true)
    self.x = 559
    self.y = 316
    self.inControl = true
end

return Timon
