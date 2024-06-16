local Scene = require "base.scene"

local Telegate1 = Scene:extend("Telegate1")

function Telegate1:new(x, y, mapLevel)
    Telegate1.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Telegate1:done()
    self.background:add("sets/bureau7", 1324, 347)
    self.background:add("sets/bureau4b", 1854, 383)
    self.background:add("coat_rack", 3290, 346)
    self.background:add("flora/set/1", 3006, 435)
    self.background:add("flora/set/1", 1120, 243, true)
    self.background:add("flora/set/1", 263, 307)
    self.background:add("flora/set/9", 2727, 435)
    self.background:add("flora/set/9", 2053, 179, true)
    self.background:add("flora/set/5", 2401, 192, true)
    self.background:add("flora/set/5", 1564, 224, true)
    self.background:add("flora/set/5", 493, 160)
    self.background:add("flora/set/4", 1158, 117)
    self.background:add("flora/set/4", 2210, 437)
    self.background:add("flora/set/3", 774, 253)
    self.background:add("flora/set/3", 1798, 253)
    self.background:add("flora/set/3", 2321, 445, true)

    self.background:add("spinnenweb_rechts_xl", 3396, 56)
    self.background:add("cam_links_diagonaal", 3426, 280)

    self.background:add("spinnenweb_rechts_m", 2589, 120)
    self.background:add("spinnenweb_links_m", 1632, 344)
    self.background:add("spinnenweb_links_m", 736, 56)
    self.background:add("spinnenweb_rechts_s", 2431, 280)
    self.background:add("spinnenweb_rechts_s", 1215, 312)

    self.background:add("ventilator2", 3242, 130)
    self.background:add("ventilator1", 2825, 130)

    self.background:add("bord_nooduitgang_rechts", 3333, 295)

    self.background:add("plafond_slierten2", 322, 56)
    self.background:add("plafond_slierten2", 2246, 120)
    self.background:add("plafond_slierten3", 1409, 120)
end

return Telegate1
