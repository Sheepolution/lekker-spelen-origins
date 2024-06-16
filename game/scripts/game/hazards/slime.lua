local SlimeDrop = require("slime_drop", ...)
local Entity = require "base.entity"

local Slime = Entity:extend("Slime")

function Slime:new(...)
    Slime.super.new(self, ...)
    self:setImage("hazards/slime", true)
    self.anim:getAnimation("idle")
        :onFrame(1, function() self.mapLevel:addEntity(SlimeDrop(self.x + 16, self.y)) end)
        :onFrame(7, function() self.mapLevel:addEntity(SlimeDrop(self.x + 6, self.y)) end)

    self:delay(_.random(3), function() self.anim:set("idle", true) end)

    self.solid = 0
    self.y = self.y + 8
end

return Slime
