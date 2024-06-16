local FlagManager = require "flagmanager"
local Background = require "background"
local Scene = require "base.scene"

local RoomManager = Scene:extend("RoomManager")

function RoomManager:init()
    if self.darkness then
        self.scene.darkness:setDarkness(self.darkness)
    end

    local room
    if self.room then
        local r = require("rooms." .. self.room)(self.x, self.y, self.mapLevel)
        r.x = self.x
        r.y = self.y
        r:setBackgroundAlpha(0)
        r.mapLevel = self.mapLevel
        r.background = self.mapLevel:add(Background(self.x, self.y))
        self.mapLevel:add(r, true)
        self.scene.room = r
    end

    if self.mapLevel.id == "Central_hub" then
        if self.scene.doorTransition then
            local cutscene = require("data.cutscenes." .. self.cutscene)
            if not cutscene.flag or not FlagManager:get(cutscene.flag) then
                self.scene:prepareCutscene(self.cutscene, self.mapLevel, room)
            end
        else
            local cutscene
            cutscene = require("data.cutscenes.teleporters_again")
            if not cutscene.flag or not FlagManager:get(cutscene.flag) then
                self.scene:prepareCutscene("teleporters_again", self.mapLevel, room)
            else
                cutscene = require("data.cutscenes.main_event2")
                if not cutscene.flag or (not FlagManager:get(cutscene.flag) and FlagManager:get(Enums.Flag.defeatedKonkie)) then
                    self.scene:prepareCutscene("main_event2", self.mapLevel, room)
                end
            end
        end
    elseif self.cutscene then
        local cutscene = require("data.cutscenes." .. self.cutscene)
        if not cutscene.flag or not FlagManager:get(cutscene.flag) then
            self.scene:prepareCutscene(self.cutscene, self.mapLevel, room)
        end
    end

    self:destroy()
end

return RoomManager
