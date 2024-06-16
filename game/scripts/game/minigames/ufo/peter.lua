local Player = require("player", ...)

local Peter = Player:extend("Peter")

function Peter:new(...)
    Peter.super.new(self, ...)

    self:setImage("minigames/ufo/peter", true)

    self.controls = {
        left = "left",
        right = "right",
        up = "up",
        down = "down",
    }
end

function Peter:update(dt)
    Peter.super.update(self, dt)
end

return Peter
