local Asset = require "base.asset"
local Sprite = require "base.sprite"

local Video = Sprite:extend("Video")

function Video:new(x, y, video, loops)
    Video.super.new(self, x, y)
    if video then
        self:setVideo(video, loops)
    end

    self.playing = false
end

function Video:update(dt)
    if self.playing then
        if not self.video:isPlaying() then
            if self.loops then
                self:restart()
            else
                self.video:rewind()
                self.video:pause()
                self.playing = false
            end
        end
    end

    Video.super.update(self, dt)
end

function Video:setVideo(video, loops)
    self.video = Asset.video(video)
    self.width, self.height = self.video:getDimensions()
    self.image = self.video
    self.loops = loops
end

function Video:play()
    self.video:play()
    self.playing = true
end

function Video:restart()
    self.video:rewind()
    self.video:play()
end

function Video:stop()
    self.video:pause()
    self.video:rewind()
    self.playing = false
end

function Video:rewind()
    self.video:rewind()
end

function Video:pause()
    self.video:pause()
    self.playing = false
end

function Video:getVideo()
    return self.video
end

return Video
