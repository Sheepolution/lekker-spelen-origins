local Pier = require "bosses.pier.pier"
local FlagManager = require "flagmanager"
local AccessPass = require "pickupables.accesspass"
local Scene = require "base.scene"

local PierRoom = Scene:extend("PierRoom")

function PierRoom:new(x, y, mapLevel)
    PierRoom.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function PierRoom:done()
    self.background:add("spinnenweb_rechts_m", 765, 56)
    self.background:add("plafond_slierten2", 178, 56)
    self.background:add("plafond_slierten4", 478, 56)

    if FlagManager:get(Enums.Flag.defeatedPier) then
        return
    end

    self.pier = self.mapLevel:add(Pier(self.x + 442, self.y + 412), true)
    self.pier.room = self

    if FlagManager:get(Enums.Flag.cutscenePierBossIntro) then
        self:initializeRestart()
    else
        self:initializeCutscene()
    end
end

function PierRoom:update(dt)
    PierRoom.super.update(self, dt)

    if self.pier and self.pier.died then
        if not self.scene:findEntityOfType(AccessPass) then
            self.scene.noDoorAccess = false
        end
    end
end

function PierRoom:onEndCutscene()
    self.pier.visible = true
    self.pier:startBossFight()
end

function PierRoom:initializeRestart()
    self.scene.noDoorAccess = true
    self.pier.visible = true

    self:delay(1, function()
        self.pier:startBossFight()
    end)

    self.scene:onInitializingBoss()
    -- self.horsey.flip.x = true

    self.scene.music:play("bosses/pier/theme", nil, true, 16.347)
end

function PierRoom:initializeCutscene()
    self.pier.visible = false
    -- self:playCutscene("pier_boss_intro")
end

function PierRoom:onPierDefeated()
    FlagManager:set(Enums.Flag.defeatedPier, true)
    self.scene.music:stop(1, true)

    self:delay(1, function()
        self.scene:startCutscene("pier_boss_defeat")
    end)
end

return PierRoom
