local Hellhound = require "bosses.hellhound.hellhound"
local Sprite = require "base.sprite"
local Music = require "base.music"
local FlagManager = require "flagmanager"
local Scene = require "base.scene"

local HellhoundRoom = Scene:extend("HellhoundRoom")

function HellhoundRoom:new(x, y, mapLevel)
    HellhoundRoom.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function HellhoundRoom:done()
    self.glass = self.mapLevel:add(Sprite(self.x + 64, self.y + 236, "decoration/horror/glass", true))
    self.glass:centerX(self.mapLevel.x + self.mapLevel.width / 2)



    if FlagManager:get(Enums.Flag.cutsceneHellhoundIntro) then
        self.glass.anim:set("break")
        if not FlagManager:get(Enums.Flag.defeatedHellhound) then
            self:initializeRestart()
        end
    else
        self.hellhound = self.mapLevel:add(Hellhound(self.x + 290, self.y + 377, self.mapLevel))
        self.hellhound.visible = false
        self.hellhound.hurtsPlayer = false
        self.hellhound.room = self
    end

    self.music = Music("sfx/cutscenes/hellhound", "breathing")
end

function HellhoundRoom:update(dt)
    self.music:update(dt)
end

function HellhoundRoom:initializeRestart(first)
    if not first then
        self.hellhound = self.mapLevel:add(Hellhound(self.x + 290, self.y + 377, self.mapLevel))
        self.hellhound.room = self
    end

    self.scene:onInitializingBoss()

    self.hellhound.hurtsPlayer = true
    self.hellhound.active = true
    self.hellhound.fighting = true
    self.scene.noDoorAccess = true
    self.scene.music:play("bosses/hellhound/theme1", nil, true)
end

function HellhoundRoom:onDefeat()
    FlagManager:set(Enums.Flag.defeatedHellhound, true)
    self.scene.noDoorAccess = false
    local door = self.scene:findEntity(function(e)
        return e.allowsEntry and e.flipped
    end)

    door.allowsEntry = false
end

return HellhoundRoom
