local Scene = require "base.scene"

local HorseyStart = Scene:extend("HorseyStart")

function HorseyStart:new(x, y, mapLevel)
    HorseyStart.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function HorseyStart:done()
    self.background:add("bord_gladde_vloer", 566, 432)
    self.background:add("klok2", 299, 353)
    self.background:add("kooi_middel", 521, 178)
    self.background:add("brandblusser_groot", 660, 395)
    self.background:add("cam_links_voor", 1226, 274)
end

return HorseyStart
