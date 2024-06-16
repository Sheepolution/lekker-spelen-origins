local Sprite = require "base.sprite"
local Scene = require "base.scene"

local Secret = Scene:extend("Secret")

function Secret:new(x, y, mapLevel)
    Secret.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Secret:done()
    self.background:add("flora/set/4", 335, 437)
    self.background:add("flora/set/7", 773, 416)
    self.background:add("flora/set/9", 153, 435)
    self.background:add("spinnenweb_links_m", 64, 56)
    self.background:add("plafond_slierten3", 264, 56)
    self.background:add("plafond_slierten4", 564, 56)
    self.background:add("cam_links_diagonaal", 867, 268)


    self.gameConsoles = self.mapLevel:add(Sprite(self.x + 186, self.y + 196, "decoration/game_consoles"), true)
end

return Secret
