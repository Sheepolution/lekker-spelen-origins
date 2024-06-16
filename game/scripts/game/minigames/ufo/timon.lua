local Player = require("player", ...)

local Timon = Player:extend("Timon")

function Timon:new(...)
    Timon.super.new(self, ...)

    self:setImage("minigames/ufo/timon", true)

    self.controls = {
        left = "a",
        right = "d",
        up = "w",
        down = "s",
    }
end

function Timon:update(dt)
    Timon.super.update(self, dt)
end

return Timon
