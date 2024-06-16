local Scene = require "base.scene"

local Telegate3 = Scene:extend("Telegate3")

function Telegate3:new(x, y, mapLevel)
    Telegate3.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Telegate3:done()
    self.background:add("bord_halt", 3565, 390)
    self.background:add("bord_halt", 3816, 390)
    self.background:add("bordje_alert", 3702, 291)
    self.background:add("bord_nooduitgang_rechts", 3918, 314)
    self.background:add("sets/bureau8", 2127, 415)
    self.background:add("sets/bureau3b", 1288, 351)
    self.background:add("sets/bureau1b", 581, 191)
    self.background:add("ventilatierooster", 2566, 292)
    self.background:add("cam_links_voor", 4009, 325)

    self.background:add("spinnenweb_rechts_l", 3984, 56)
    self.background:add("spinnenweb_links_s", 2720, 376)
    self.background:add("spin_hoog", 2746, 376)
    self.background:add("ventilator1", 3158, 100)
    self.background:add("flora/set/14", 1766, 448)
    self.background:add("flora/set/2", 3608, 477)
    self.background:add("flora/set/2", 2561, 413)
    self.background:add("flora/set/2", 96, 221)
    self.background:add("flora/set/1", 3791, 467)
    self.background:add("flora/set/1", 1585, 467)
    self.background:add("flora/set/1", 422, 211)
    self.background:add("prullenbak_met_toetsenbord", 451, 447)
    self.background:add("plafond_slierten2", 3538, 56)
    self.background:add("plafond_slierten2", 1655, 120)
end

return Telegate3
