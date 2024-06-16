local Scene = require "base.scene"

local Telegate2 = Scene:extend("Telegate2")

function Telegate2:new(x, y, mapLevel)
    Telegate2.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Telegate2:done()
    self.background:add("cam_rechts_horizontaal", 64, 265)
    self.background:add("vat_radioactief", 1479, 237)
    self.background:add("prullenbak_open", 3735, 428)

    self.background:add("sets/bureau10", 983, 212)
    self.background:add("sets/bureau3b", 3288, 383)
    self.background:add("bord_nooduitgang_links", 117, 289)
    self.background:add("spinnenweb_links_l", 64, 56)

    self.background:add("plafond_slierten2", 1565, 88)
    self.background:add("plafond_slierten2", 3744, 376)

    self.background:add("flora/set/2", 739, 445)
    self.background:add("flora/set/2", 2022, 285)
    self.background:add("flora/set/2", 3392, 253)

    self.background:add("flora/set/3", 1201, 445)
    self.background:add("flora/set/3", 2357, 253, true)
    self.background:add("flora/set/3", 4020, 445)

    self.background:add("flora/set/9", 2236, 147)
    self.background:add("flora/set/9", 3689, 435)

    self.background:add("bordje_alert", 2494, 245)
    self.background:add("ventilatierooster", 4288, 558)

    self.background:add("kapstok", 227, 348)
end

return Telegate2
