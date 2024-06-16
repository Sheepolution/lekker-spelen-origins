local Pickupable = require "pickupables.pickupable"

local Keycard = Pickupable:extend("Keycard")

function Keycard:new(...)
    Keycard.super.new(self, ...)
    self:setImage("pickupables/keycard", true)
    self.solid = 0
    self.holdable = true
    self.sniffable = true
    self.sfx = "keycard"
end

function Keycard:done()
    self.anim:set(self.colorType:lower())
end

function Keycard:update(dt)
    Keycard.super.update(self, dt)
end

return Keycard
