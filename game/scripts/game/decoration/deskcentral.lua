local Sprite = require "base.sprite"
local Entity = require "base.entity"

local DeskCentral = Entity:extend("DeskCentral")

function DeskCentral:new(...)
    DeskCentral.super.new(self, ...)
    self:setImage("decoration/desk_central", true)
    self.offset.y = 6

    self:addHitbox("solid", 0, -8, 64, 32)
end

function DeskCentral:update(dt)
    self.computer:update(dt)
    DeskCentral.super.update(self, dt)
end

function DeskCentral:draw()
    DeskCentral.super.draw(self)
    self.computer:drawAsChild(self, nil, nil, true)
end

function DeskCentral:startComputer()
    self.computer.anim:set("turnon")
end

return DeskCentral
