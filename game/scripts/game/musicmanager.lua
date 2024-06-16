local Class = require "base.class"
local MusicManager = Class:extend("MusicManager")

function MusicManager:init()
    local callback = function()
        if not self.scene then
            self.destroyed = true
            return
        end

        if self.volume and self.volume > 0 then
            local default = self.scene.music:getDefaultVolume()
            self.scene.music:setVolume(self.volume * default)
        end

        if self.effects then
            -- local song = self.scene.music:getSong(self.path)

            -- local name = "effect_" .. self.scene.map:getCurrentLevel().id
            -- love.audio.setEffect(name, self.effects)
            -- song:setEffect(name)
        end

        self.scene.music:play(self.path, 1, true, self.loop_time)

        self.destroyed = true
    end

    if self.scene.preparedCutscenes[self.mapLevel] then
        self.scene.musicCallbackAfterCutscene = callback
    else
        callback()
    end
end

return MusicManager
