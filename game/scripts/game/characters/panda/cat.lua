local Entity = require "base.entity"

local Cat = Entity:extend("Cat")

function Cat:new(...)
    Cat.super.new(self, ...)
    self:setImage("bosses/panda/cat", true)
    self.x = 288
    self.y = 239
    self.anim:set("play")
end

function Cat:update(dt)
    Cat.super.update(self, dt)
end

return Cat
