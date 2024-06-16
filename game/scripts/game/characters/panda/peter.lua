local Player = require("player", ...)

local Peter = Player:extend("Peter")

function Peter:new(...)
    Peter.super.new(self, ...)
    self:setImage("bosses/panda/peter", true)
    self.x = 347
    self.y = 374
    self.inControl = true
end

return Peter
