local FlagManager = require "flagmanager"
local Pickupable = require "pickupables.pickupable"

local Papflap = Pickupable:extend("Papflap")

function Papflap:new(...)
    Papflap.super.new(self, ...)
    self:setImage("pickupables/papflap")
    self.sfx = "papflap"
end

function Papflap:update(dt)
    Papflap.super.update(self, dt)
end

function Papflap:onPickedUp(e)
    Papflap.super.onPickedUp(self)
    e:increaseHealth(1)

    if not FlagManager:get(Enums.Flag.ateMiniPapflap) then
        FlagManager:set(Enums.Flag.ateMiniPapflap, true)
        self.scene:delay(1, function()
            self.scene:showNotification("Dat was een mini-papflap!\n\nJe krijgt er alleen een hartje van terug.")
        end)
    end
end

return Papflap
