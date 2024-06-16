local FlagManager = require "flagmanager"
local Scene = require "base.scene"

local Hub = Scene:extend("Hub")

function Hub:new(x, y, mapLevel)
    Hub.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Hub:done()
end

function Hub:update(dt)
    Hub.super.update(self, dt)
end

return Hub
