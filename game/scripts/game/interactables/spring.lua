local Point = require "base.point"
local Interactable = require("interactable", ...)

local Spring = Interactable:extend("Spring")

function Spring:new(...)
    Spring.super.new(self, ...)
    self:setImage("interactables/spring", true)
    self.anim:getAnimation("trigger"):onComplete(self.F({ triggered = false }))

    self.y = self.y - 52
    self.linePosition = Point(self:centerX(), self:bottom() - 35)

    self:addHitbox(0, 12, self.width, 8, nil, true)
    self.animations.on = "idle_on"
    self.animations.off = "idle_off"
end

function Spring:onBeingUsed()
    self.anim:set("trigger")
    self.triggered = true
    self.scene.sfx:play("interactables/spring", "reverb")
end

function Spring:onStateChanged()
    Spring.super.onStateChanged(self)
    if not self.on then self.triggered = false end
end

return Spring
