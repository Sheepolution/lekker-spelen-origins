local FlagManager = require "flagmanager"
local Pickupable = require "pickupables.pickupable"

local AccessPass = Pickupable:extend("AccessPass")

function AccessPass:new(...)
    AccessPass.super.new(self, ...)
    self:setImage("pickupables/access_pass", true)

    self.mapDestructionType = Pickupable.mapDestructionType.Permanent
    self.mapPermanentDestruction = true

    self.sfx = "keycard"
end

function AccessPass:done()
    self.anim:set(tostring(self.access))
end

function AccessPass:update(dt)
    AccessPass.super.update(self, dt)
end

function AccessPass:onPickedUp()
    AccessPass.super.onPickedUp(self)
    FlagManager:set(Enums.Flag["hasAccessPass" .. self.access], true)
end

return AccessPass
