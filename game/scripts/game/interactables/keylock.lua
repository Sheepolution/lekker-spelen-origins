local Interactable = require("interactable", ...)

local Keylock = Interactable:extend("Keylock")

function Keylock:new(...)
    Keylock.super.new(self, ...)
    self:setImage("interactables/keylock", true)
    self.y = self.y - 9
    self.solid = 0
    self.immovable = true
    self.stateChanger = true

    self.sfx = {
        on = "keylock",
    }
end

function Keylock:done()
    self.animations.on = "on_" .. self.colorType:lower()
    self.animations.off = "off_" .. self.colorType:lower()
    self.anim:set(self.animations.off)
    Keylock.super.done(self)
end

function Keylock:update(dt)
    Keylock.super.update(self, dt)
end

function Keylock:onOverlap(i)
    if i.e.tile then
        return false
    end

    if i.e.playerEntity == true then
        local card = i.e.holdingItem
        if card then
            if card.colorType == self.colorType then
                card:destroy()
                i.e.holdingItem = nil
                self:changeState(true)
            end
        end
    end
end

return Keylock
