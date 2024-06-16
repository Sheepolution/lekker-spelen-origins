local Scene = require "base.scene"

local HorrorStart = Scene:extend("HorrorStart")

function HorrorStart:new(x, y, mapLevel)
    HorrorStart.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function HorrorStart:done()
    self.background:add("flora/set/7", 357, 416)
    self.background:add("flora/set/6", 288, 447)
    self.background:add("flora/set/4", 509, 437)
    self.background:add("flora/set/5", 730, 415)
    self.background:add("bord_halt", 809, 362)
    self.background:add("cam_links_diagonaal", 867, 272)
end

return HorrorStart
