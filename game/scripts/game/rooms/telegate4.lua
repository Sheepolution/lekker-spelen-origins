local Scene = require "base.scene"

local Telegate4 = Scene:extend("Telegate4")

function Telegate4:new(x, y, mapLevel)
    Telegate4.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Telegate4:done()
    self.background:add("cam_rechts_diagonaal", 63, 298)
    self.background:add("sets/bureau5", 960, 218)
    self.background:add("sets/bureau4", 2496, 148)
    self.background:add("krijtbord_tapir_met_snor", 2767, 165)
    self.background:add("brandblusser_groot", 4285, 389)
    self.background:add("plafond_slierten4", 3381, 56)

    self.background:add("sets/chemistry3", 3011, 328)
    self.background:add("sets/chemistry1", 3582, 82)
    self.background:add("sets/chemistry5", 3821, 354)

    self.background:add("flora/set/14", 1764, 96)
    self.background:add("flora/set/3", 468, 477)
    self.background:add("flora/set/3", 1825, 317)
    self.background:add("flora/set/3", 3379, 445, true)
    self.background:add("flora/set/3", 4307, 157)

    self.background:add("bord_nooduitgang_links", 143, 316)
    self.background:add("sets/bureau3b", 1986, 255)

    self.background:add("spinnenweb_links_s", 960, 408)
    self.background:add("spinnenweb_rechts_l", 2128, 88)
end

return Telegate4
