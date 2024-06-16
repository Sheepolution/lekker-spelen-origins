local Asset = require "base.asset"
local Sprite = require "base.sprite"
local Scene = require "base.scene"

local Speech = Scene:extend("Ending")

function Speech:new(...)
    Speech.super.new(self, ...)

    self.speech = self:add(Sprite(180, 50, "cutscenes/speech/speech_big"))
    self.speech.origin:set(0, 0)
    self.speech.scale:set(.5)
    self.speech:setFilter("linear", "linear")

    self.camera:setWorld(-200, -200, WIDTH * 4, HEIGHT * 4)
    self.camera:moveToPoint(WIDTH / 2, HEIGHT / 2)

    self:setFilter("linear", "linear")

    self:setBackgroundColor(23, 23, 23)
    self.speechAudio = Asset.audio("sfx/cutscenes/speech/speech")

    self:fadeIn(1, function()
        self:toSpeech()
    end)

    self.imgItch = self:add(Sprite(0, 0, "cutscenes/speech/itchio"))
    self.imgItch:centerToScreen()
    self.imgItch.y = self.imgItch.y + HEIGHT

    self.imgSoundtrack = self:add(Sprite(0, 0, "cutscenes/speech/ost"))
    self.imgSoundtrack:centerToScreen()
    self.imgSoundtrack.x = self.imgSoundtrack.x + WIDTH
    self.imgSoundtrack.y = self.imgSoundtrack.y + HEIGHT

    self.imgSpeaker = self:add(Sprite(0, 0, "cutscenes/speech/speaker"))
    self.imgSpeaker:centerToScreen()
    self.imgSpeaker.x = self.imgSpeaker.x + WIDTH

    self.imgHandInPocket = self:add(Sprite(0, 0, "cutscenes/speech/hand_in_pocket"))
    self.imgHandInPocket:centerToScreen()
    self.imgHandInPocket.visible = false

    self.imgNintendo = self:add(Sprite(0, 0, "cutscenes/speech/nintendo_guy"))
    self.imgNintendo:centerToScreen()
    self.imgNintendo.y = self.imgNintendo.y + HEIGHT
    self.imgNintendo.visible = false

    self.imgAnnouncement = self:add(Sprite(0, 0, "cutscenes/speech/announcement"))
    self.imgAnnouncement:centerToScreen()
    self.imgAnnouncement.x = self.imgAnnouncement.x + WIDTH
    self.imgAnnouncement.y = self.imgAnnouncement.y + HEIGHT
    self.imgAnnouncement.visible = false

    self.imgArtbook1 = self:add(Sprite(0, 0, "cutscenes/speech/artbook1"))
    self.imgArtbook1:centerToScreen()
    self.imgArtbook1.x = self.imgArtbook1.x + WIDTH
    self.imgArtbook1.visible = false

    self.imgArtbook2 = self:add(Sprite(0, 0, "cutscenes/speech/artbook2"))
    self.imgArtbook2:centerToScreen()
    self.imgArtbook2.visible = false

    self.imgArtbook3 = self:add(Sprite(0, 0, "cutscenes/speech/artbook3"))
    self.imgArtbook3:centerToScreen()
    self.imgArtbook3.y = self.imgArtbook3.y + HEIGHT
    self.imgArtbook3.visible = false

    self.imgArtbook4 = self:add(Sprite(0, 0, "cutscenes/speech/artbook4"))
    self.imgArtbook4:centerToScreen()
    self.imgArtbook4.visible = false

    self.imgLekkerLief = self:add(Sprite(0, 0, "credits/lekkerlief", true))
    self.imgLekkerLief:centerToScreen()
    self.imgLekkerLief.visible = false
    self.imgLekkerLief.scale:set(2)
end

function Speech:update(dt)
    Speech.super.update(self, dt)
end

function Speech:draw()
    Speech.super.draw(self)
    if self.video then
        love.graphics.draw(self.video, 0, 0, 0, .5, .5)
    end
end

function Speech:toSpeech()
    self.speechAudio:play()

    self:tween(self.speech, 8.5, { y = -50 }):delay(4):ease("linear")
        :after(1, { y = -640 }):ease("backout")

    -- Itch url
    self.camera:tweenToRelativePoint(0, HEIGHT, .5)
        :delay(18.5)
        :ease("backout")
    -- OST
        :after(.25, { x = self.camera.x + WIDTH })
        :delay(7.5)
        :ease("backout")
    -- Speaker
        :after(.25, { y = self.camera.y })
        :delay(6)
        :oncomplete(function()
            self.speech.visible = false
            self.imgItch.visible = false
            self.imgSoundtrack.visible = false
            self.imgHandInPocket.visible = true
            self.imgAnnouncement.visible = true
            self.imgNintendo.visible = true
        end)
        :ease("backout")
    -- Hand in pocket
        :after(.25, { x = self.camera.x })
        :delay(3)
        :ease("quintin")
    -- Nintendo guy
        :after(.25, { y = self.camera.y + HEIGHT })
        :delay(2)
        :ease("quadout")
    -- Announcement
        :after(.25, { x = self.camera.x + WIDTH })
        :delay(3)
        :ease("quadout")
        :oncomplete(function()
            self.imgSpeaker.visible = false
            self.imgHandInPocket.visible = false
            self.imgNintendo.visible = false
            self.imgArtbook1.visible = true
        end)
    -- Art book 1
        :after(.25, { y = self.camera.y })
        :delay(21.5)
        :ease("quintin")
        :oncomplete(function()
            self.imgArtbook2.visible = true
            self.imgArtbook3.visible = true
        end)
    -- Art book 2
        :after(.25, { x = self.camera.x })
        :delay(6.8)
        :ease("quadin")
    -- Art book 3
        :after(.25, { y = self.camera.y + HEIGHT })
        :delay(7.5)
        :ease("quadin")
        :oncomplete(function()
            self.imgArtbook2.visible = false
            self.imgArtbook4.visible = true
            self.imgArtbook1.visible = false
            self.imgSpeaker.visible = true
        end)
    -- Art book 4
        :after(.25, { y = self.camera.y })
        :delay(12.5)
        :ease("quintin")
    -- Speaker
        :after(.25, { x = self.camera.x + WIDTH })
        :delay(9)
        :ease("quintin")
        :oncomplete(function()
            self.imgArtbook4.visible = false
            self.imgLekkerLief.visible = true
        end)
    -- LekkerLief
        :after(.25, { x = self.camera.x })
        :delay(2)
        :ease("quintin")
        :oncomplete(function()
            self:delay(7, function()
                self:fadeOut(6, function()
                    self.scene:setScene()
                    self.scene:toMainMenu(true)
                end)
            end)
            self:event(function()
                self.coil.wait(1.5)
                local lief = self:add(Sprite(_.random(50, WIDTH - 100), _.random(50, HEIGHT - 100), "credits/lekkerlief",
                    true))
                lief.scale:set(2)
                self.coil.wait(.4)
                lief = self:add(Sprite(_.random(50, WIDTH - 100), _.random(50, HEIGHT - 100), "credits/lekkerlief", true))
                lief.scale:set(2)
                self.coil.wait(.4)
                lief = self:add(Sprite(_.random(50, WIDTH - 100), _.random(50, HEIGHT - 100), "credits/lekkerlief", true))
                lief.scale:set(2)
                self.coil.wait(.4)
                lief = self:add(Sprite(_.random(50, WIDTH - 100), _.random(50, HEIGHT - 100), "credits/lekkerlief", true))
                lief.scale:set(2)
                self.coil.wait(.4)
                lief = self:add(Sprite(_.random(50, WIDTH - 100), _.random(50, HEIGHT - 100), "credits/lekkerlief", true))
                lief.scale:set(2)
                self.coil.wait(3)
                for i = 1, 100 do
                    lief = self:add(Sprite(_.random(50, WIDTH - 100), _.random(50, HEIGHT - 100), "credits/lekkerlief",
                        true))
                    lief.scale:set(2)
                    self.coil.wait(.25)
                end
            end, nil, 1)
        end)

    self.speech.rounding = false
end

function Speech:start()
end

return Speech
