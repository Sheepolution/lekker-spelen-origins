local Scene = require "base.scene"

local HorseyLevel = Scene:extend("HorseyLevel")

function HorseyLevel:new(x, y, mapLevel)
    HorseyLevel.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function HorseyLevel:done()
    self.background:add("spinnenweb_links_m", 64, 504)
    self.background:add("sets/bureau4", 2509, 628)
    self.background:add("sets/office_supplies", 2866, 666)
    self.background:add("sets/office_supplies", 4505, 666)
    self.background:add("sets/bureau2", 4722, 624)
    self.background:add("hibernation_tube_bg", 2763, 574)
    self.background:add("plafond_slierten1", 4730, 248)
    self.background:add("hibernation_tube_bg", 4980, 574)
    self.background:add("deur_buiten_gebruik", 7445, 432)
    self.background:add("ventilator1", 12964, 410)
    self.background:add("cam_links_diagonaal", 16579, 558)
    self.background:add("bordje_alert", 16960, 698)
    self.background:add("flora/set/4", 16033, 533)
    self.background:add("flora/set/6", 17216, 735)

    self.background:add("spinnenweb_links_l", 3936, 376)
    self.background:add("spinnenweb_links_l", 8032, 440)
    self.background:add("spinnenweb_links_l", 12144, 376, true)
    self.background:add("spinnenweb_links_l", 16032, 600)

    self.background:add("spinnenweb_links_s", 991, 536, true)
    self.background:add("spinnenweb_links_s", 4832, 88)
    self.background:add("spinnenweb_links_s", 5951, 696, true)
    self.background:add("spinnenweb_links_s", 17888, 846)

    self.background:add("sets/bureau5b", 9179, 475)
    self.background:add("sets/bureau3", 9467, 443)
    self.background:add("sets/bureau6", 9023, 462)

    self.background:add("sets/bookcase2", 14387, 414)
    self.background:add("sets/bureau7", 14512, 443)
    self.background:add("sets/bureau9", 13683, 462)
    self.background:add("sets/bureau5", 14126, 475)
    self.background:add("sets/bureau8b", 13934, 479)

    self.background:add("flora/set/14", 944, 736)
    self.background:add("flora/set/14", 3901, 576)
    self.background:add("flora/set/14", 5525, 192)
    self.background:add("flora/set/14", 13557, 576)
    self.background:add("flora/set/14", 17721, 736)

    self.background:add("flora/set/7", 1570, 576)
    self.background:add("flora/set/7", 5397, 160)
    self.background:add("flora/set/7", 6597, 736)
    self.background:add("flora/set/9", 7136, 755)
    self.background:add("flora/set/9", 12841, 275)
    self.background:add("flora/set/9", 16141, 179)
    self.background:add("flora/set/9", 17609, 723)

    self.background:add("cam_links_voor", 17801, 577)
end

return HorseyLevel
