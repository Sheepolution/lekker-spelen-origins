local Scene = require "base.scene"

local HorseyStart = Scene:extend("HorseyStart")

function HorseyStart:new(x, y, mapLevel)
    HorseyStart.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function HorseyStart:done()
    self.background:add("sets/bureau1", 925, 301)
    self.background:add("logo_labklein", 1099, 326)
    self.background:add("spinnenweb_rechts_l", 1648, -40)
end

return HorseyStart
