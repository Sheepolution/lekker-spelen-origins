local Block = require "objects.block"
local Interactable = require("interactable", ...)

local BlockSpawner = Interactable:extend("BlockSpawner")

function BlockSpawner:new(...)
    BlockSpawner.super.new(self, ...)
    self:setImage("interactables/blockspawner")
    self.offset.y = 8
    self.solid = 0
    self.spawnBlockCooldown = step.after(1)
    self.spawnBlockCooldown:finish(true)
end

function BlockSpawner:done()
    BlockSpawner.super.done(self)
end

function BlockSpawner:update(dt)
    BlockSpawner.super.update(self, dt)
    self.spawnBlockCooldown(dt)
end

function BlockSpawner:onStateChanged()
    if self.on then
        self:spawnBox()
    end
    self.on = false
end

function BlockSpawner:spawnBox()
    if not self.spawnBlockCooldown(0) then return end

    local delay = .01
    if self.box then
        self.box:kill()
        delay = .3
    end

    self:delay(delay, function()
        self.box = self.mapLevel:add(Block(self.x, self.y))
    end)

    self.spawnBlockCooldown()
end

return BlockSpawner
