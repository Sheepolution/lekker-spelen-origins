local Scene = require "base.scene"

local HorseyEnd = Scene:extend("HorseyEnd")

function HorseyEnd:new(x, y, mapLevel)
    HorseyEnd.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function HorseyEnd:done()
    self.background:add("spinnenweb_links_m", 64, 56)
    self.background:add("plafond_slierten2", 537, 56)
    self.background:add("logo_labklein", 489, 258)
end

return HorseyEnd
