local Player = require "characters.players.player"
local Entity = require "base.entity"

local Reviver = Entity:extend("Reviver")

function Reviver:new(...)
    Reviver.super.new(self, ...)
    self:setImage("interactables/checkpoint", true)
    self.anim:set("off")
    self.touched = false
    self.solid = 2
    self.immovable = true
    self.hitbox = self:addHitbox(0, 60, self.width * .8, 5)
    self.detectBox = self:addHitbox(0, -HEIGHT / 2 + 40, self.width * .5, HEIGHT)
    self.detectBox.solid = false
end

function Reviver:done()
    Reviver.super.done(self)
end

function Reviver:update(dt)
    Reviver.super.update(self, dt)
end

function Reviver:onOverlap(i)
    if i.e:is(Player) then
        if not self.touched then
            self.anim:set("on")
            self.scene.sfx:play("interactables/teleporter_on")
            self.touched = true
            self.scene:onReachingCheckpoint(self)
        end
    end
end

return Reviver
