local Flow = require "base.components.flow"
local Class = require "base.class"
local Asset = require "base.asset"

local Music = Class:extend("Music")

Music:implement(Flow)

Music.maxVolume = CONFIG.defaultMusicMax
Music.instances = list()

function Music:new(directory, ...)
    self.defaultVolume = CONFIG.defaultMusicVolume
    self.previousVolume = 0
    self.currentVolume = self.defaultVolume
    self.muted = false

    self.directory = directory or ""
    self.songs = {}
    for i, songName in ipairs({ ... }) do
        self:addSong(songName)
    end

    Flow.new(self)

    Music.instances:add(self)
end

function Music:update(dt)
    Flow.update(self, dt)

    if self.justRestarted then
        local song = self:getSong()
        if not song then return end
        if song:tell() > 1 then
            self.justRestarted = false
        end
    end

    if self.loopPoint and not self.justRestarted then
        local song = self:getSong()
        if not song then return end
        local duration = song:getDuration()
        -- if song:tell() > duration - 0.017 - dt then
        if song:tell() > duration - 0.017 or song:tell() == 0 then
            song:seek(self.loopPoint)
            song:play()
        end
    end
end

function Music:addSong(name)
    local song = Asset.audio(self.directory .. "/" .. name, OS.WEB)
    song:setLooping(true)
    song:setVolume(0)
    self.songs[name] = song
    return song
end

function Music:pause(transition)
    if not self.currentSong then return end
    if self.stopped then return end

    self.paused = true

    if transition then
        self.previousVolume = self.currentVolume
        self:_startCurrentSongTween(transition, 0, function() self.currentSong:pause() end)
    else
        self.previousVolume = self.currentVolume
        self.currentSong:pause()
    end
end

function Music:resume(transition)
    if not self.currentSong then return end
    if not self.paused then return end
    if self.stopped then return end

    self.paused = false

    self.currentSong:play()

    if transition then
        self:_startCurrentSongTween(transition, self.previousVolume)
    else
        self.currentVolume = self.previousVolume or self.defaultVolume
        self:_updateCurrentVolume()
    end
end

function Music:stop(transition, clear)
    if not self.currentSong then return end

    self.paused = false
    self.stopped = true

    if transition then
        self:_startCurrentSongTween(transition, 0, function()
            self.currentSong:stop()
            if clear then self:clear() end
        end)
    else
        self.currentSong:stop()
        if clear then
            self:clear()
        end
    end
end

function Music:start(name)
    if not self.songs[name] then
        self:addSong(name)
    end

    local song = self.songs[name]
    song:setVolume(0)
    song:play()
end

function Music:play(name, transition, restart, loopPoint, volume)
    if type(name) ~= "string" then
        self:resume(name)
        return
    end

    if not self.songs[name] then
        self:addSong(name)
    elseif self.currentSong == self.songs[name] and self.currentSong:isPlaying() then
        return
    end

    if self.currentSong and self.currentSong:isPlaying() and not self.stopped then
        self.previousVolume = self.currentVolume
        self.previousSong = self.currentSong
        if transition then
            self:_startPreviousSongTween(transition)
        else
            -- self.previousSong:stop()
            self.previousSong:setVolume(0)
            self.previousSong = nil
        end
    else
        self.previousSong = nil
        self.previousVolume = nil
    end

    self.paused = false
    self.stopped = false

    self.currentSong = self.songs[name]
    self.currentSongPath = name
    if restart then
        self.currentSong:stop()
        self.justRestarted = true
    end
    self.currentSong:play()

    self.loopPoint = loopPoint

    if self.loopPoint then
        self.currentSong:setLooping(false)
    end

    if transition then
        self.currentVolume = 0
        self:_updateCurrentVolume()
        self:_startCurrentSongTween(transition, volume or self.previousVolume)
    else
        self.currentVolume = self.defaultVolume
        self:_updateCurrentVolume()
    end

    return self:getSong()
end

function Music:isPlaying()
    return self.currentSong and self.currentSong:isPlaying()
end

function Music:setDefaultVolume(volume)
    self.defaultVolume = volume
end

function Music:getDefaultVolume()
    return self.defaultVolume
end

function Music:setVolume(volume, transition, force)
    if not self.currentSongTween or force then
        if self.currentSongTween then
            self.currentSongTween:stop()
        end
        if transition then
            self:_startCurrentSongTween(transition, volume)
        else
            self.currentVolume = volume
            self:_updateCurrentVolume()
        end
    end
end

function Music:getVolume()
    return self.currentVolume
end

function Music:mute()
    if self.muted then return end
    self.muted = true

    if self.previousSong then
        self.previousSong:setVolume(0)
    end

    if self.currentSongTween then
        self.currentSongTween:stop()
    end

    self.currentSong:setVolume(0)
end

function Music:unmute()
    if not self.muted then return end
    self.muted = false
    self:_updateCurrentVolume()
end

function Music:toggleMute()
    if self.muted then
        self:unmute()
    else
        self:mute()
    end
end

function Music:getSong(name)
    if not name then
        return self.currentSong
    else
        if not self.songs[name] then
            self:addSong(name)
        end

        return self.songs[name]
    end
end

function Music:_startPreviousSongTween(time)
    if self.previousSongTween then
        self.previousSongTween:stop()
    end

    self.previousSongTween = self:tween(time, { previousVolume = 0 })
        :onupdate(self.wrap:_updatePreviousVolume())
        :oncomplete(function()
            self.previousSongTween = nil
            -- self.previousSong:stop()
        end)
        :ease("circout")
end

function Music:_startCurrentSongTween(time, volume, callback)
    if self.currentSongTween then
        self.currentSongTween:stop()
    end

    self.currentSongTween = self:tween(time, { currentVolume = (volume or self.defaultVolume) })
        :onupdate(self.wrap:_updateCurrentVolume())
        :oncomplete(function()
            self.currentSongTween = nil
            if callback then callback() end
        end)
        :ease("circout")
end

function Music:_updatePreviousVolume()
    if self.muted then
        return
    end

    self.previousSong:setVolume(self.previousVolume * Music.maxVolume)
end

function Music:_updateCurrentVolume()
    if self.muted and self.currentVolume > 0 then
        return
    end

    if self.currentSong then
        self.currentSong:setVolume((self.currentVolume or self.defaultVolume) * Music.maxVolume)
    end
end

function Music:destroy()
    if self.currentSong then
        self.currentSong:stop()
    end

    Music.instances:remove_value(self)
end

function Music.updateMaxVolume(max)
    Music.maxVolume = CONFIG.defaultMusicMax * max
    for _, music in ipairs(Music.instances) do
        music:_updateCurrentVolume()
    end
end

function Music:clear()
    if self.currentSong then
        self.currentSong:stop()
    end

    self.currentSong = nil
end

return Music
