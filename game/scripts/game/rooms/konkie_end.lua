local Scene = require "base.scene"

local KonkieEnd = Scene:extend("KonkieEnd")

function KonkieEnd:new(x, y, mapLevel)
    KonkieEnd.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function KonkieEnd:done()
    self.background:add("spinnenweb_links_xl", 64, 56)
    self.background:add("plafond_slierten3", 516, 56)
    self.background:add("logo_labklein", 489, 290)
end

return KonkieEnd
