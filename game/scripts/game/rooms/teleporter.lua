local Button = require "interactables.button"
local FlagManager = require "flagmanager"
local Scene = require "base.scene"

local Teleporter = Scene:extend("Teleporter")

function Teleporter:new(x, y, mapLevel)
    Teleporter.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Teleporter:done()
    local button = self.scene:findEntityWithTag("Button")

    if FlagManager:get(Enums.Flag.activatedTeleportPlatforms) then
        for i, v in ipairs(button.connectionEntities) do
            v:changeState(true)
        end
    else
        button.onInteract = function(b)
            Button.onInteract(b)
            FlagManager:set(Enums.Flag.activatedTeleportPlatforms, true)
        end
    end

    self.background:add("flora/set/5", 712, 576)
    self.background:add("sets/chemistry6", 1481, 487)
    self.background:add("sets/bureau5", 2302, 538)
    self.background:add("flora/set/6", 2953, 543)
    self.background:add("flora/set/7", 3530, 384)
    self.background:add("sets/bureau9b", 3237, 526)
    self.background:add("bord_nooduitgang_rechts", 4145, 456)
    self.background:add("bordje_alert", 319, 456)
    self.background:add("ventilator1", 1457, 292)
    self.background:add("flora/set/5", 2667, 512)
    self.background:add("flora/set/5", 4091, 576, true)
    self.background:add("flora/set/9", 2059, 403)
    self.background:add("flora/set/9", 3785, 403)
    self.background:add("flora/set/9", 943, 595, true)
    self.background:add("flora/set/12", 1757, 398)
    self.background:add("flora/set/12", 3817, 590)
    self.background:add("sets/bureau7b", 1102, 543)
    self.background:add("sets/bureau10b", 2335, 543)
    self.background:add("spinnenweb_links_m", 2048, 248)
    self.background:add("spinnenweb_links_m", 3648, 536)
    self.background:add("spinnenweb_rechts_l", 3024, 408)
    self.background:add("ventilator1", 2851, 239)
    self.background:add("plafond_slierten2", 2439, 248)
end

return Teleporter
