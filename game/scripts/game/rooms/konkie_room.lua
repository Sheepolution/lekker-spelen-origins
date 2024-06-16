local Input = require "base.input"
local Asset = require "base.asset"
local moonshine = require "libs.moonshine"
local KonkieBoss = require "bosses.konkie.konkie"
local Sprite = require "base.sprite"
local Scene = require "base.scene"
local DeathScreen = require "bosses.konkie.death_screen"
local Text = require "base.text"
local FlagManager = require "flagmanager"
local Video = require "base.video"

local KonkieRoom = Scene:extend("KonkieRoom")

function KonkieRoom:new(x, y, mapLevel)
    KonkieRoom.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
    self.deathScreen = DeathScreen()
    self.deathScreen.removeOnLevelChange = true
end

function KonkieRoom:done()
    self.background:add("bananen", 81, 311)
    if FlagManager:get(Enums.Flag.defeatedKonkie) then
        self.glass = self.mapLevel:add(Sprite(self.x + 64, self.y + 24, "bosses/konkie/glass", true))
        self.glass.z = 100
        self.glass.anim:set("broken")

        return
    end

    self.scene:setDeathScreen(self.deathScreen)

    self.konkie = KonkieBoss(self.x, self.y)
    self.konkie.room = self

    if FlagManager:get(Enums.Flag.cutsceneKonkieIntro) then
        self:initializeRestart()
    else
        self:initializeCutscene()
    end
end

function KonkieRoom:initializeRestart(first)
    -- TODO
    -- FINAL: true
    self.scene.noDoorAccess = false

    if not DEBUG then
        self.scene.noDoorAccess = true
    end

    self.scene:onInitializingBoss()

    self:delay(2, function()
        self.scene.music:play("bosses/konkie/phase1", nil, true)
        self.scene.music:start("bosses/konkie/phase2", nil, true)
        self.scene.music:start("bosses/konkie/phase3", nil, true)
    end)

    self.phase = 1

    self.mapLevel:add(self.konkie, true)
    self.konkie.z = 105

    self.glass = self.mapLevel:add(Sprite(self.x + 64, self.y + 24, "bosses/konkie/glass", true))
    self.glass.z = 100
    self.glass.anim:set("broken")

    self.textReady = self.scene:addOverlay(Text(0, 0, "Klaar?", "oregano", 200))
    self.textReady:setAlign("center", WIDTH)
    self.textReady:center(WIDTH / 2, HEIGHT / 2 - 150)
    self.textReady:setFilter("linear", "linear")
    self.textReady.shadow:set(3, 3)
    self.textReady.z = -101
    self.textReady.alpha = 0
    self.textReady.removeOnLevelChange = true

    self.textGo = self.scene:addOverlay(Text(0, 0, "BEGIN!", "dubba_dubba", 200))
    self.textGo:setAlign("center", WIDTH)
    self.textGo:center(WIDTH / 2, HEIGHT / 2 - 120)
    self.textGo:setFilter("linear", "linear")
    self.textGo.z = -101
    self.textGo.alpha = 0
    self.textGo.removeOnLevelChange = true

    -- TODO: Fix that player can still move at the start
    self.scene:getPlayers()(function(e) e.inControl = false end)

    local effect = moonshine(moonshine.effects.chromasep)
    effect.chromasep.radius = WIDTH / love.graphics.getWidth()
    self.scene.effects = effect
    self.scene.showEffects = true

    self.video = self.scene:addOverlay(Video(0, 0, "bosses/konkie/grain2", true))
    self.video.origin:set(0, 0)
    self.video.scale:set(1.2, 1.2)
    self.video:setBlend("screen")
    self.video:play()
    self.video.z = ZMAP.DeathScreen - 1
    self.video.removeOnLevelChange = true

    self:event(function()
        self.coil.wait(first and 2 or .2)
        Asset.audio("sfx/bosses/konkie/announcer/ready" .. _.random(1, 4, true)):play()
        self:tween(self.textReady, .5, { alpha = 1 })
        self.coil.wait(2.4)
        Asset.audio("sfx/bosses/konkie/announcer/go" .. _.random(1, 4, true)):play()
        self.scene:getPlayers()(function(e) e.inControl = true end)

        self.konkie:toNextState()
        self.textReady:destroy()
        self.textGo.visible = true
        self.textGo.alpha = 1
        for __ = 1, 5 do
            self.coil.wait(.05)
            self.textGo:setColor(0, 0, 0)
            self.coil.wait(.05)
            self.textGo:setColor(255, 255, 255)
        end
        self.textGo:destroy()
    end, nil, 1)
end

function KonkieRoom:draw()
    KonkieRoom.super.draw(self)
end

function KonkieRoom:initializeCutscene()
    self.smallKonkie = self.mapLevel:add(Sprite(0, self.y + 347, "bosses/konkie/small_konkie", true))
    self.smallKonkie.anim:set("eat")
    self.smallKonkie:centerX(self.x + WIDTH / 2)
    self.smallKonkie.z = 105

    self.laser = self.mapLevel:add(Sprite(0, self.mapLevel.y, "bosses/konkie/laserbeam", true))
    self.laser.anim:getAnimation("turn_on"):onComplete(function()
        self.smallKonkie.anim:set("beamed")
    end)
    self.laser.anim:set("off")
    self.laser:centerX(self.x + WIDTH / 2 + 10)
    self.laser.z = 108

    local SFX = require "base.sfx"
    local sfx_thump = SFX("sfx/bosses/konkie/glass_bonk2")
    local sfx_break = SFX("sfx/bosses/konkie/glass_break")

    self.glass = self.mapLevel:add(Sprite(self.x + 64, self.y + 24, "bosses/konkie/glass", true))
    self.glass.anim:getAnimation("explosion")
        :onFrame(6, function()
            self.scene:shake(3, .2)
            sfx_thump:play("reverb")
            Input:rumble(1, .5, .2)
            Input:rumble(2, .5, .2)
        end)
        :onFrame(7, function()
            self.scene:shake(6, .4)
            sfx_thump.pitch = 1.05
            sfx_thump:play("reverb")
            Input:rumble(1, .6, .3)
            Input:rumble(2, .6, .3)
        end)
        :onFrame(8, function()
            sfx_thump.pitch = 1.1
            sfx_thump:play("reverb")
            self.scene:shake(9, .6)
            Input:rumble(1, .7, .3)
            Input:rumble(2, .7, .3)
        end)
        :onFrame(9, function()
            self.scene:shake(10, .3)
            Input:rumble(1, .8, .2)
            Input:rumble(2, .8, .2)
        end)
        :onFrame(11, function()
            sfx_break:play()
            self.smallKonkie:destroy()
            self.laser:destroy()
            self.button:destroy()
            self:initializeRestart(true)
        end)

    self.glass.anim:set("idle")
    self.glass.z = 100

    self.button = self.mapLevel:add(Sprite(0, self.mapLevel.y + 456, "bosses/konkie/button", true))
    self.button:centerX(self.x + WIDTH / 2 + 25)
    self.button.z = 99
    self.button.anim:set("off")
end

function KonkieRoom:destroy()
    KonkieRoom.super.destroy(self)
end

function KonkieRoom:onKonkieDefeated()
    self.textKnockout = self.scene:addOverlay(Text(0, 0, "KNOCKOUT!!", "oregano", 100))
    self.textKnockout:setAlign("center", WIDTH)
    self.textKnockout:center(WIDTH / 2, HEIGHT / 2 - 50)
    self.textKnockout:setFilter("linear", "linear")
    self.textKnockout.z = -101
    self.textKnockout.removeOnLevelChange = true
    local players = self.scene:getPlayers()

    FlagManager:set(Enums.Flag.defeatedKonkie, true)

    Asset.audio("sfx/bosses/konkie/announcer/knockout"):play()

    self:tween(self.konkie, 4, { y = self.konkie.y + 200 }):ease("linear")

    self.scene:setDeathScreen()

    players(function(e)
        e.inControl = false
        e.hurtable = false
        e:stopMoving("x")
        e.lastInputDirection = nil
        e.movementDirection = nil
    end)

    self:event(function()
        for __ = 1, 12 do
            self.coil.wait(.05)
            self.textKnockout:setColor(0, 0, 0)
            self.coil.wait(.05)
            self.textKnockout:setColor(255, 255, 255)
        end

        self.textKnockout:destroy()
    end, nil, 1)

    self:delay(3, function()
        self.scene:fadeOut(1, function()
            self.konkie:destroy()
            self.textKnockout:destroy()
            self.scene:findEntitiesWithTag("Banana"):destroy()
            self.scene.music:stop(1, true)

            self.video:destroy()
            self.scene.effects = nil

            self.scene:fadeIn(1, function()
                players(function(e)
                    e.inControl = true
                    e.hurtable = true
                end)
                self.scene.noDoorAccess = false
            end, false)
        end)
    end)
end

function KonkieRoom:onKonkieNextPhase()
    self.phase = self.phase + 1
    self.scene.music:play("bosses/konkie/phase" .. self.phase, 3)
end

return KonkieRoom
