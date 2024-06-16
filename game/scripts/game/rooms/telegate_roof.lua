local Scene = require "base.scene"

local TelegateRoof = Scene:extend("TelegateRoof")

function TelegateRoof:new(x, y, mapLevel)
    TelegateRoof.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function TelegateRoof:done()
    self.background:add("flora/set/1", 185, 434)
    self.background:add("flora/set/3", 385, 444)
    self.background:add("flora/set/4", 793, 444)
    self.background:add("plafond_slierten2", 537, 56)
    self.background:add("bord_nooduitgang_onder", 677, 237)
end

return TelegateRoof
