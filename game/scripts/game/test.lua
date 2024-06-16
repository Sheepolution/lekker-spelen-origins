local Entity = require "base.entity"

local Test = Entity:extend("Test")

function Test:new(...)
    Test.super.new(self, ...)
    self:setImage("test")
end

function Test:update(dt)
    Test.super.update(self, dt)
end

return Test
