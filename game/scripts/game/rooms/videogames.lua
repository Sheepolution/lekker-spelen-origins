local Scene = require "base.scene"

local Videogames = Scene:extend("Videogames")

function Videogames:new(x, y, mapLevel)
    Videogames.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Videogames:done()
    self.background:add("sets/bureau6", 580, 366)
    self.background:add("cam_rechts_diagonaal", 63, 273)
    self.background:add("ventilatierooster", 790, 134)
    self.background:add("plafond_slierten2", 1193, 536)
    self.background:add("flora/set/2", 1320, 445)
    self.background:add("flora/set/5", 387, 416)
    self.background:add("flora/set/7", 1969, 416)
    self.background:add("flora/set/4", 2266, 181)
    self.background:add("flora/set/6", 2463, 447)
    self.background:add("flora/set/8", 2349, 448)
    self.background:add("flora/set/9", 2724, 435)
    self.background:add("cam_links_voor", 3370, 273)
    self.background:add("ventilatierooster", 952, 606)
    self.background:add("plafond_slierten2", 2218, 273)
    self.background:add("plafond_slierten1", 2424, 536)
    self.background:add("spinnenweb_links_l", 2272, 760)
    self.background:add("flora/set/1", 2613, 883)
    self.background:add("brandblusser_groot", 3060, 611)
    self.background:add("flora/set/3", 2749, 701)
    self.background:add("ventilator1", 1720, 549)
    self.background:add("flora/set/1", 525, 435)
    self.background:add("flora/set/5", 1141, 128)
    self.background:add("flora/set/4", 675, 757)
    self.background:add("flora/set/7", 1081, 736)
    self.background:add("flora/set/7", 2459, 800)
    self.background:add("flora/set/8", 2860, 448)
    self.background:add("flora/set/8", 1804, 672)
    self.background:add("flora/set/9", 815, 627)
    self.background:add("flora/set/10", 1371, 603)
    self.background:add("flora/set/10", 2949, 443, true)
    self.background:add("flora/set/10", 2916, 446)
    self.background:add("flora/set/12", 1668, 430)
    self.background:add("sets/bureau1b", 3456, 990)
    self.background:add("flora/set/5", 3456, 990, true)
end

return Videogames
