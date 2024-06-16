local TileGroup = require "base.map.tilegroup"
local FlagManager = require "flagmanager"
local SFX = require "base.sfx"
local Entity = require "base.entity"

local SecurityGate = Entity:extend("SecurityGate")

SecurityGate.SFX = {
    open = SFX("sfx/interactables/security_gate_open", 4),
}

function SecurityGate:new(...)
    SecurityGate.super.new(self, ...)
    self:setImage("interactables/security_gate", true)
    self.anim:getAnimation("open"):onComplete(self.F:destroy())
    self.y = self.y - 8
    self:addIgnoreCollision(TileGroup)
    self.solid = 2
    self.immovable = true
end

function SecurityGate:done()
    SecurityGate.super.done(self)
    self.anim:set("closed_" .. self.level)
end

function SecurityGate:update(dt)
    if not self.opening then
        local player, distance = self.scene:findNearestPlayer(self)
        if player and distance < 200 then
            if self:hasAccess() then
                self.anim:set("open")
                self.SFX.open:play("reverb")
                self.opening = true
            end
        end
    end

    SecurityGate.super.update(self, dt)
end

function SecurityGate:hasAccess()
    return FlagManager:get(Enums.Flag["hasAccessPass" .. self.level])
end

return SecurityGate
