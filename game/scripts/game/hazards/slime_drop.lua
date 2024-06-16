local Entity = require "base.entity"

local SlimeDrop = Entity:extend("SlimeDrop")

function SlimeDrop:new(...)
    SlimeDrop.super.new(self, ...)
    self:setImage("hazards/slime_drop", true)
    self.anim:getAnimation("fall"):onComplete(self.F:destroy())
    self.hurtsPlayer = true

    self.gravity = 1000
    self.solid = 0
    self:delay(.25, self.F({ solid = 1 }))
    self.z = ZMAP.IN_FRONT_OF_PLAYERS
end

function SlimeDrop:update(dt)
    SlimeDrop.super.update(self, dt)
end

function SlimeDrop:onSeparate(...)
    SlimeDrop.super.onSeparate(self, ...)
    self.anim:set("fall")
    self.hurtsPlayer = false
end

return SlimeDrop
