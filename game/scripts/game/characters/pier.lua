local Entity = require "base.entity"

local Pier = Entity:extend("Pier")

function Pier:new(...)
    Pier.super.new(self, ...)
    self:setImage("characters/pier", true)
    self.solid = 0
    self.offset.y = -6
end

function Pier:update(dt)
    Pier.super.update(self, dt)
end

return Pier
