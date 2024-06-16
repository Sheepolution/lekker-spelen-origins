local Entity = require "base.entity"

local Sicko = Entity:extend("Sicko")

function Sicko:new(...)
    Sicko.super.new(self, ...)
    self:setImage("characters/sicko", true)
    self.anim:set("idle")

    self.smokeEmitTimer = step.every(3, 4)
end

function Sicko:update(dt)
    Sicko.super.update(self, dt)

    if self.smokeEmitTimer(dt) then
        local smoke = self:emit("sickoSmoke", 20, -3, self.flip.x)
        smoke.z = self.visible and -3 or 95
    end
end

return Sicko
