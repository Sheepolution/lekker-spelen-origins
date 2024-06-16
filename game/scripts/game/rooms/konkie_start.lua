local Scene = require "base.scene"

local KonkieStart = Scene:extend("KonkieStart")

function KonkieStart:new(x, y, mapLevel)
    KonkieStart.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function KonkieStart:done()
    self.background:add("plafond_slierten1", 310, 56)
    self.background:add("plafond_slierten3", 738, 56)
    self.background:add("cam_links_voor", 874, 264)
end

return KonkieStart
