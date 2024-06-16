local Scene = require "base.scene"

local KonkieStart2 = Scene:extend("KonkieStart2")

function KonkieStart2:new(x, y, mapLevel)
    KonkieStart2.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function KonkieStart2:done()
    self.background:add("flora/set/1", 349, 467)
    self.background:add("flora/set/7", 742, 446)
    self.background:add("sets/bureau2", 78, 368)
    self.background:add("sets/cages4", 558, 391)
    self.background:add("plafond_slierten5", 242, 56)
    self.background:add("plafond_slierten4", 774, 56)
    self.background:add("flora/set/1", 349, 467)
end

return KonkieStart2
