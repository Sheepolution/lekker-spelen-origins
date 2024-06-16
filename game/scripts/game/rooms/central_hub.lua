local Placement = require "base.components.placement"
local Gier = require "decoration.gier"
local Scene = require "base.scene"

local CentralHub = Scene:extend("CentralHub")

function CentralHub:new(x, y, mapLevel)
    CentralHub.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function CentralHub:done()
    self.background:add("ventilator1", 646, 230)
    self.background:add("ventilator2", 1228, 230)
    self.background:add("logo_lab_groot", 940, 317)
    self.background:add("deur_planken", 909, 369)
    self.background:add("flora/set/9", 1018, 499)
    self.background:add("flora/set/5", 934, 480, true)
    self.background:add("bord_nooduitgang_rechts", 1767, 288)
    self.background:add("sets/cafetaria", 577, 823)
    self.background:add("spinnenweb_links_xl", 224, 1080)
    self.background:add("ventilatierooster", 314, 1121)
    self.background:add("plafond_slierten2", 1644, 1080)
    self.background:add("ventilatierooster", 1594, 1121)
    self.background:add("spin_midden", 1415, 1304)
    self.background:add("spinnenweb_rechts_s", 1151, 1528)
    self.background:add("poster_rd", 927, 1554)
    self.background:add("poster_werknemer", 977, 1548)
    self.background:add("poster_kapitein_koek", 1048, 1536)
    self.background:add("krijtbord_koek", 779, 1541)
    self.background:add("sets/kitchen", 1102, 1127)
    self.background:add("sets/table_with_syrup", 914, 1197)
    self.background:add("bord_gladde_vloer", 824, 1231)
    self.background:add("deur_bord1", 73, 832)
    self.background:add("deur_bord2", 1822, 832)
    self.background:add("deur_bord3", 73, 1442)
    self.background:add("deur_bord4", 1822, 1442)

    self.background:add("flora/set/2", 537, 509)
    self.background:add("flora/set/2", 1446, 1501)
    self.background:add("flora/set/2", 1673, 765, true)
    self.background:add("flora/set/3", 799, 508)
    self.background:add("flora/set/3", 515, 1116)
    self.background:add("flora/set/3", 1579, 1628)
    self.background:add("flora/set/5", 1231, 608)
    self.background:add("flora/set/5", 292, 1344)
    self.background:add("flora/set/5", 1212, 1600)
    self.background:add("flora/set/12", 297, 750)
    self.background:add("flora/set/12", 1454, 878)
    self.background:add("flora/set/12", 634, 1614, true)
    self.background:add("flora/set/13", 588, 608)
    self.background:add("flora/set/13", 1450, 1216)
    self.background:add("flora/set/6", 275, 1023)
    self.background:add("flora/set/6", 1443, 639)
    self.background:add("flora/set/6", 1651, 1375)
    self.background:add("flora/set/4", 482, 885)
    self.background:add("flora/set/4", 445, 1493, true)
    self.background:add("flora/set/4", 1415, 1109, true)

    self.background:add("spinnenweb_rechts_l", 528, 696)
    self.background:add("spinnenweb_rechts_l", 1296, 824)
    self.background:add("spinnenweb_rechts_s", 1631, 1432)
    self.background:add("spinnenweb_rechts_s", 1631, 600)
    self.background:add("plafond_slierten4", 497, 1304)
    self.background:add("plafond_slierten4", 1386, 696)
    self.background:add("plafond_slierten3", 406, 568)

    local gier = self.scene:add(Gier(self.x + 845, self.y + 883))
    gier.removeOnLevelChange = true
end

return CentralHub
