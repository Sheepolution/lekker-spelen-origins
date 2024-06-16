local Player = require "characters.players.player"
local Entity = require "base.entity"

local Checkpoint = Entity:extend("Checkpoint")

function Checkpoint:new(...)
    Checkpoint.super.new(self, ...)
    self.visible = false
    self.touched = false
    self.solid = 0
    self.immovable = true
end

function Checkpoint:done()
    Checkpoint.super.done(self)
    self:addHitbox()
end

function Checkpoint:update(dt)
    Checkpoint.super.update(self, dt)
end

function Checkpoint:onOverlap(i)
    if self.boss then
        return
    end
    if not self.touched then
        if i.e:is(Player) then
            self.touched = true
            self.scene:onReachingCheckpoint(self)
        end
    end
end

return Checkpoint
