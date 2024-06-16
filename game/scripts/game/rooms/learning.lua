local Scene = require "base.scene"

local Learning = Scene:extend("Learning")

function Learning:new(x, y, mapLevel)
    Learning.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Learning:done()
    self.background:add("flora/set/9", 893, 115)
    self.background:add("spinnenweb_links_l", 65, 280)
    self.background:add("flora/set/2", 557, 413)
    self.background:add("flora/set/5", 2102, 352)
    self.background:add("sets/bureau10b", 819, 415)
    self.background:add("sets/chemistry3", 1344, 264)
    self.background:add("sets/bookcase", 1884, 227)
    self.background:add("ventilatierooster", 681, 64)
    self.background:add("spinnenweb_rechts_m", 2205, 120)
    self.background:add("sets/bureau2", 2534, 272)
    self.background:add("flora/set/4", 2474, 181)
    self.background:add("flora/set/1", 3704, 83)
    self.background:add("flora/set/5", 3945, 320)
    self.background:add("sets/chemistry4", 3120, 200)
    self.background:add("bord_nooduitgang_rechts", 4461, 200)
    self.background:add("flora/set/6", 1122, 383)
    self.background:add("flora/set/10", 1987, 347)
    self.background:add("sets/bureau6b", 4261, 287)
    self.background:add("sets/cages3", 1530, 167)
    self.background:add("bureau_stoel_gevallen1", 3615, 334)
    self.background:add("flora/set/13", 3564, 320)
    self.background:add("flora/set/12", 3707, 334)
    self.background:add("flora/set/3", 2954, 253)
    self.background:add("ventilator1", 2141, 162)
    self.background:add("plafond_slierten4", 1393, 24)
    self.background:add("spinnenweb_links_s", 2400, 56)
    self.background:add("ventilatierooster", 3457, 97)
    self.background:add("ventilator2", 3861, 137)
    self.background:add("plafond_slierten1", 2972, 56)
    self.background:add("flora/set/4", 1052, 117, true)
end

return Learning
