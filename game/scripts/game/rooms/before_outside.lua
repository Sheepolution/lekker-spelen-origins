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
    self.background:add("flora/set/5", 584, 416)
    self.background:add("flora/set/8", 105, 448)
    self.background:add("flora/set/9", 466, 435, true)
    self.background:add("bord_nooduitgang_rechts", 784, 300)
end

return TelegateRoof
