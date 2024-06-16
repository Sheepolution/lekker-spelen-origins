local Scene = require "base.scene"

local PandaEnd = Scene:extend("PandaEnd")

function PandaEnd:new(x, y, mapLevel)
    PandaEnd.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function PandaEnd:done()
    self.background:add("spinnenweb_rechts_xl", 836, 56)
    self.background:add("plafond_slierten4", 316, 56)
    self.background:add("logo_labklein", 489, 258)
end

return PandaEnd
