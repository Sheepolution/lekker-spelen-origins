local Sprite = require "base.sprite"
local Scene = require "base.scene"
local Text = require "base.text"
local SFX = require "base.sfx"
local Save = require "base.save"
local Input = require "base.input"

local Cutscene = Scene:extend("Cutscene")

local keys = {
    { "c1_a", "space" },
    { "c2_a", "space" }
}

if not DEBUG then
    keys = {
        { "c1_a" },
        { "c2_a", "space", "z", "s" }
    }
end

function Cutscene:new(tag, callback)
    Cutscene.super.new(self, 0, 0, 1920, 1080)

    self.callback = callback

    self.sprites = list()

    tag = tag:lower()

    if tag == "peter" then
        self:loadPeter()
    else
        self:loadTimon()
    end

    self:setFilter("linear")

    self.SFX = {}

    if tag == "peter" then
        self.SFX.peter_victory = SFX("sfx/cutscenes/death/peter_victory")
        self.SFX.peter_look = SFX("sfx/cutscenes/death/peter_look")
        self.SFX.peter_concerned = SFX("sfx/cutscenes/death/peter_concerned")
        self.SFX.peter_sad = SFX("sfx/cutscenes/death/peter_sad")
        self.SFX.peter_scream = SFX("sfx/cutscenes/death/peter_scream")
    else
        self.SFX.timon_victory = SFX("sfx/cutscenes/death/timon_victory")
        self.SFX.timon_look = SFX("sfx/cutscenes/death/timon_look")
        self.SFX.timon_concerned = SFX("sfx/cutscenes/death/timon_concerned")
        self.SFX.timon_sad = SFX("sfx/cutscenes/death/timon_sad")
        self.SFX.timon_scream = SFX("sfx/cutscenes/death/timon_scream")
    end

    self.current = 0

    self.canShowNextDelay = step.after(1)

    self.lightningSFX = SFX("sfx/cutscenes/death/lightning")

    self.winnerTag = tag
end

function Cutscene:done()
    self.scene.ambience:setDefaultVolume(.5)
    self.scene.ambience:play("rain_wind")
end

function Cutscene:update(dt)
    local controllerId = Save:get("settings.controls." .. self.winnerTag:lower() .. ".player1") and 1 or 2

    if self.canShowNextDelay(dt) and self.current > 0 then
        if Input:isPressed(keys[controllerId]) then
            if self.winnerTag == "peter" then
                self:showNextPeter()
            else
                self:showNextTimon()
            end
        end
    end

    Cutscene.super.update(self, dt)
end

function Cutscene:draw()
    CANVAS:draw(function()
        Cutscene.super.draw(self)
    end)
end

function Cutscene:loadPeter()
    self.background = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/background1")))
    self.background.z = 20
    self.peterDown = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/peter_down")))
    self.peterDown.alpha = 0

    self.peterLook = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/peter_look")))
    self.peterLook.alpha = 0

    self.peterConcerned = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/peter_concerned")))
    self.peterConcerned.alpha = 0

    self.timonDeath = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/timon_death")))
    self.timonDeathLightning = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/timon_death_lightning")))
    self.timonDeath.visible = false
    self.timonDeathLightning.alpha = 0
    self.timonDeathLightning.z = -1

    self.timonDeath.scale:set(1.1)
    self.timonDeathLightning.scale:set(1.1)
    self.timonDeath:setFilter("linear")
    self.timonDeathLightning:setFilter("linear")
    self.timonDeath.offset.y = -60
    self.timonDeathLightning.offset.y = -60

    self.peterSad = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/peter_sad")))
    self.peterSad.visible = false

    self.rain1 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/rain1_1")))
    self.rain2 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/rain1_2")))
    self.rain1.z = -10
    self.rain2.z = -10

    self.rainTimon1 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/rain2_1")))
    self.rainTimon2 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_peter/rain2_2")))
    self.rainTimon1.visible = false
    self.rainTimon2.visible = false
    self.rainTimon1.z = -10
    self.rainTimon2.z = -10

    self.dialogueRectangle = self:add(Sprite(0, 0, "cutscenes/dialogue_rect"))
    self.dialogueRectangle:center(WIDTH, 1000)
    self.dialogueRectangle:setColor(0, 0, 0)
    self.dialogueRectangle.alpha = .5
    self.dialogueRectangle.z = -20

    self.dialogue = self:add(Text(WIDTH, 980, "HAHAHA YES! Ik ben Main Event! IK!", "calibri", 48))
    self.dialogue:setAlign("center", WIDTH * 2)
    self.dialogue.z = -30

    self.dialogue.offset.y = 200
    self.dialogueRectangle.offset.y = 200
    self:initRainTweensPeter()
    self:delay(1.5, self.F:showNextPeter())
end

function Cutscene:loadTimon()
    self.background1 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/background1")))
    self.background2 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/background2")))
    self.background2.alpha = 0
    self.background1.z = 20
    self.background2.z = 20
    self.timonHappy = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/timon_happy")))
    self.timonHappy.alpha = 0

    self.timonLook = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/timon_look")))
    self.timonLook.alpha = 0

    self.timonConcerned = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/timon_concerned")))
    self.timonConcerned.alpha = 0

    self.peterDeath = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/peter_death")))
    self.peterDeathLightning = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/peter_death_lightning")))
    self.peterDeath.visible = false
    self.peterDeathLightning.alpha = 0
    self.peterDeathLightning.z = -1

    self.peterDeath.scale:set(1.1)
    self.peterDeathLightning.scale:set(1.1)
    self.peterDeath:setFilter("linear")
    self.peterDeathLightning:setFilter("linear")
    self.peterDeath.offset.y = -60
    self.peterDeathLightning.offset.y = -60

    self.timonSad = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/timon_sad")))
    self.timonSad.visible = false

    self.rain1_1 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/rain1_1")))
    self.rain1_2 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/rain1_2")))
    self.rain1_1.z = -10
    self.rain1_2.z = -10

    self.rain2_1 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/rain2_1")))
    self.rain2_2 = self.sprites:add(self:add(Sprite(0, 0, "cutscenes/victory_timon/rain2_2")))
    self.rain2_1.visible = false
    self.rain2_2.visible = false
    self.rain2_1.z = -10
    self.rain2_2.z = -10

    self.dialogueRectangle = self:add(Sprite(0, 0, "cutscenes/dialogue_rect"))
    self.dialogueRectangle:center(WIDTH, 1000)
    self.dialogueRectangle:setColor(0, 0, 0)
    self.dialogueRectangle.alpha = .5
    self.dialogueRectangle.z = -20

    self.dialogue = self:add(Text(WIDTH, 980, "YEEEEEEES BAABYYY! Ik ben officieel die MAIN EVENT!", "calibri", 48))
    self.dialogue:setAlign("center", WIDTH * 2)
    self.dialogue.z = -30

    self.dialogue.offset.y = 200
    self.dialogueRectangle.offset.y = 200
    self:initRainTweensTimon()
    self:delay(1.5, self.F:showNextTimon())
end

function Cutscene:showNextPeter()
    self.current = self.current + 1

    if self.current == 1 then
        self.peterDown.x = -100
        self:tween(self.peterDown, .5, { x = 0, alpha = 1 })
        self.canShowNextDelay()
        self:tween(self.dialogue.offset, .5, { y = 0 })
        self:tween(self.dialogueRectangle.offset, .5, { y = 0 })
        self.SFX.peter_victory:play()
    elseif self.current == 2 then
        self:tween(self.peterDown, .5, { alpha = 0 }):ease("quadout")
        self:tween(self.peterLook, .5, { alpha = 1 }):ease("quadout")
        self.dialogue:write("Hoor je dat Timon?! Dringt het door in dat zielige koppie van je?!")
        self.canShowNextDelay()
        self.SFX.peter_look:play()
    elseif self.current == 3 then
        self:tween(self.peterLook, .5, { alpha = 0 }):ease("quadout")
        self:tween(self.peterConcerned, .5, { alpha = 1 }):ease("quadout")
        self.dialogue:write("Timon...?")
        self.canShowNextDelay()
        self.SFX.peter_concerned:play()
    elseif self.current == 4 then
        self.rain1.visible = false
        self.rain2.visible = false
        self.rainTimon1.visible = true
        self.rainTimon2.visible = true

        self.timonDeath.visible = true
        self:delay(.4, function()
            self.lightningSFX:play()
            self.timonDeathLightning.alpha = 1
            self:tween(self.timonDeathLightning, .8, { alpha = 0 }):delay(.8)
        end)

        self.dialogue.offset.y = 200
        self.dialogueRectangle.offset.y = 200
        self:tween(self.dialogue.offset, .5, { y = 0 }):delay(2)
        self:tween(self.dialogueRectangle.offset, .5, { y = 0 }):delay(2)
            :onstart(function() self.SFX.peter_sad:play() end)

        self.canShowNextDelay:set(4)
        self.dialogue:write("Timon... Timon word wakker!")
        self:tween(self.timonDeath.offset, 1.5, { y = 0 })
        self:tween(self.timonDeathLightning.offset, 1.5, { y = 0 })
    elseif self.current == 5 then
        self.rain1.visible = true
        self.rain2.visible = true
        self.rainTimon1.visible = false
        self.rainTimon2.visible = false
        self.peterSad.visible = true
        self.dialogue:write("TIIIIIMOOOOOONNN!!!!")

        self.dialogue.y = -180
        self.dialogueRectangle.y = -200
        self.camera:moveToPoint(WIDTH, HEIGHT)
        self:tween(self.dialogue, .2, { y = 190 }):delay(.3)
        self:tween(self.dialogueRectangle, .2, { y = 150 }):delay(.3)
        self.canShowNextDelay:set(2)

        self.camera:zoomTo(3)
        self.camera:zoomTo(1, .5)
        self.SFX.peter_scream:play()
    elseif self.current == 6 then
        self:tween(self.dialogue, .2, { alpha = 0 })
        self:tween(self.dialogueRectangle, .2, { alpha = 0 })
        self:delay(1.5, self.F:fadeOut(3, function()
            self:destroy()
            self.callback()
        end))
    end
end

function Cutscene:showNextTimon()
    self.current = self.current + 1

    if self.current == 1 then
        self.timonHappy.x = 50
        self:tween(self.timonHappy, .5, { x = 0, alpha = 1 })
        self.canShowNextDelay()
        self:tween(self.dialogue.offset, .5, { y = 0 })
        self:tween(self.dialogueRectangle.offset, .5, { y = 0 })
        self.SFX.timon_victory:play("reverb")
    elseif self.current == 2 then
        self:tween(self.timonHappy, .5, { alpha = 0 }):ease("quadout")
        self:tween(self.timonLook, .5, { alpha = 1 }):ease("quadout")
        self.dialogue:write("Hoor je dat Peter?! Dringt het door in dat domme koppie van je?!")
        self.canShowNextDelay()
        self.SFX.timon_look:play("reverb")
    elseif self.current == 3 then
        self:tween(self.timonLook, .5, { alpha = 0 }):ease("quadout")
        self:tween(self.timonConcerned, .5, { alpha = 1 }):ease("quadout")
        self:tween(self.background2, .5, { alpha = 1 }):ease("quadout")
        self.dialogue:write("Peter...?")
        self.canShowNextDelay()
        self.SFX.timon_concerned:play("reverb")

        self.rain1_1.visible = false
        self.rain1_2.visible = false
        self.rain2_1.visible = true
        self.rain2_2.visible = true
    elseif self.current == 4 then
        self.rain1_1.visible = true
        self.rain1_2.visible = true
        self.rain2_1.visible = false
        self.rain2_2.visible = false

        self.peterDeath.visible = true
        self:delay(.4, function()
            self.lightningSFX:play()
            self.peterDeathLightning.alpha = 1
            self:tween(self.peterDeathLightning, .8, { alpha = 0 }):delay(.8)
        end)

        self.dialogue.offset.y = 200
        self.dialogueRectangle.offset.y = 200
        self:tween(self.dialogue.offset, .5, { y = 0 }):delay(2)
        self:tween(self.dialogueRectangle.offset, .5, { y = 0 }):delay(2)
            :onstart(function() self.SFX.timon_sad:play("reverb") end)

        self.canShowNextDelay:set(4)
        self.dialogue:write("Peter... Peter word wakker!")
        self:tween(self.peterDeath.offset, 1.5, { y = 0 })
        self:tween(self.peterDeathLightning.offset, 1.5, { y = 0 })
    elseif self.current == 5 then
        self.rain1_1.visible = false
        self.rain1_2.visible = false
        self.rain2_1.visible = true
        self.rain2_2.visible = true

        self.timonSad.visible = true
        self.dialogue:write("PEEEEETEEEEEERRR!!!!")

        self.dialogue.y = -180
        self.dialogueRectangle.y = -200
        self.camera:moveToPoint(WIDTH, HEIGHT)
        self:tween(self.dialogue, .2, { y = 190 }):delay(.3)
        self:tween(self.dialogueRectangle, .2, { y = 150 }):delay(.3)
        self.canShowNextDelay:set(2)

        self.camera:zoomTo(3)
        self.camera:zoomTo(1, .5)
        self.SFX.timon_scream:play("reverb")
    elseif self.current == 6 then
        self:tween(self.dialogue, .2, { alpha = 0 })
        self:tween(self.dialogueRectangle, .2, { alpha = 0 })
        self:delay(1.5, self.F:fadeOut(3, function()
            self:destroy()
            self.callback()
        end))
    end
end

function Cutscene:initRainTweensPeter()
    local rain1_tween
    rain1_tween = function()
        self.rain1.x = 0
        self.rain1.y = -300
        self.rain1.alpha = 1
        self:tween(self.rain1, .5, { x = -160, y = 200, alpha = 0 })
            :oncomplete(function()
                rain1_tween()
            end)
    end

    local rain2_tween
    rain2_tween = function()
        self.rain2.x = 0
        self.rain2.y = -300
        self.rain2.alpha = 1
        self:tween(self.rain2, .5, { x = -160, y = 200, alpha = 0 })
            :oncomplete(function()
                rain2_tween()
            end)
    end

    self.rain2.alpha = 0
    rain1_tween()
    self:delay(.25, rain2_tween)


    local rain_timon1_tween
    rain_timon1_tween = function()
        self.rainTimon1.alpha = .8
        self.rainTimon1.scale:set(1.5)
        self:tween(self.rainTimon1, .39, { alpha = 0 })
        self:tween(self.rainTimon1.scale, .4, { x = .25, y = .25 })
            :ease("quadout")
            :oncomplete(function()
                rain_timon1_tween()
            end)
    end

    local rain_timon2_tween
    rain_timon2_tween = function()
        self.rainTimon2.alpha = .8
        self.rainTimon2.scale:set(1.5)
        self:tween(self.rainTimon2, .39, { alpha = 0 })
        self:tween(self.rainTimon2.scale, .4, { x = .25, y = .25 })
            :ease("quadout")
            :oncomplete(function()
                rain_timon2_tween()
            end)
    end

    rain_timon1_tween()
    self:delay(.2, rain_timon2_tween)
end

function Cutscene:initRainTweensTimon()
    local rain1_1_tween
    rain1_1_tween = function()
        self.rain1_1.x = 0
        self.rain1_1.y = -300
        self.rain1_1.alpha = 1
        self:tween(self.rain1_1, .5, { x = -160, y = 200, alpha = 0 })
            :oncomplete(function()
                rain1_1_tween()
            end)
    end

    local rain1_2_tween
    rain1_2_tween = function()
        self.rain1_2.x = 0
        self.rain1_2.y = -300
        self.rain1_2.alpha = 1
        self:tween(self.rain1_2, .5, { x = -160, y = 200, alpha = 0 })
            :oncomplete(function()
                rain1_2_tween()
            end)
    end

    local rain2_1_tween
    rain2_1_tween = function()
        self.rain2_1.x = 0
        self.rain2_1.y = -300
        self.rain2_1.alpha = 1
        self:tween(self.rain2_1, .5, { x = -160, y = 200, alpha = 0 })
            :oncomplete(function()
                rain2_1_tween()
            end)
    end

    local rain2_2_tween
    rain2_2_tween = function()
        self.rain2_2.x = 0
        self.rain2_2.y = -300
        self.rain2_2.alpha = 1
        self:tween(self.rain2_2, .5, { x = -160, y = 200, alpha = 0 })
            :oncomplete(function()
                rain2_2_tween()
            end)
    end

    self.rain1_2.alpha = 0
    rain1_1_tween()
    self:delay(.25, rain1_2_tween)
    rain2_1_tween()
    self:delay(.25, rain2_2_tween)

    -- self.rain2.alpha = 0
    -- rain1_tween()
    -- self:delay(.25, rain2_tween)


    -- local rain_timon1_tween
    -- rain_timon1_tween = function()
    --     self.rainTimon1.alpha = .5
    --     self.rainTimon1.scale:set(2)
    --     self:tween(self.rainTimon1, .49, { alpha = 0 })
    --     self:tween(self.rainTimon1.scale, .5, { x = .25, y = .25 })
    --         :ease("quadout")
    --         :oncomplete(function()
    --             rain_timon1_tween()
    --         end)
    -- end

    -- local rain_timon2_tween
    -- rain_timon2_tween = function()
    --     self.rainTimon2.alpha = .5
    --     self.rainTimon2.scale:set(2)
    --     self:tween(self.rainTimon2, .49, { alpha = 0 })
    --     self:tween(self.rainTimon2.scale, .5, { x = .25, y = .25 })
    --         :ease("quadout")
    --         :oncomplete(function()
    --             rain_timon2_tween()
    --         end)
    -- end

    -- rain_timon1_tween()
    -- self:delay(.25, rain_timon2_tween)
end

return Cutscene
