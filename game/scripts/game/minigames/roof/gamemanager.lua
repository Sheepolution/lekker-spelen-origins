local RoofThunder = require "decoration.roof_thunder"
local Rect = require "base.rect"
local Player = require("player", ...)
local Sprite = require "base.sprite"
local Entity = require "base.entity"
local Music = require "base.music"
local SFX = require "base.sfx"
local Scene = require "base.scene"

local GameManager = Scene:extend("GameManager")

function GameManager:new(player, callback)
    GameManager.super.new(self)

    self:setMap("roof", 0)

    self.player = self:add(Player(350, 300, player))
    -- Change to 82
    self:delay(82, function()
        self.thunder:setNoLightningSFX()
        self.scene.ambience:stop(5)
    end)
    -- Change to 82
    self:delay(82, self.F:fadeOut(3, function()
        self.player.inControl = false
        self:delay(5, function()
            self:destroy()
            callback()
        end)
    end))

    self:delay(60, function()
        self.thunder:showStars()
    end)

    self.music = Music("music/minigames/roof", "regrets")
    self.music:play("regrets")

    self.z = -50

    self.thunder = self:addUnderlay(RoofThunder())
    self.thunder.lightningInterval = step.every(7, 12)

    self:setBackgroundImage("minigames/roof/background")

    self:setBackgroundColor(36, 31, 61)
    self.darknessOverlay = self:addOverlay(Rect(0, 0, 960, 540))
    self.darknessOverlay.alpha = .4
    self.darknessOverlay.z = ZMAP.TOP
    self.darknessOverlay:setColor(0, 0, 0)

    self.shadowBig = self:add(Sprite(100, 450, "minigames/roof/shadow_big"))
    self.shadowBig.z = 100

    self.camera:follow(self.player, true)
    self.camera.lerp = 1.8
    self.camera:setWorld(0, 0, 960 * 7, 540)

    self.rainDropList = list()

    self.currentFlashback = 0
    self.flashbacks = list()

    for i = 1, 4 do
        local flashback = self.flashbacks:add(self:addOverlay(Sprite(0, 50, "minigames/roof/flashbacks/" .. i)))
        flashback:centerX(i % 2 == 0 and 200 or 750)
        flashback.visible = false
    end

    for i = 1, 10 do
        local drop = self:add(Sprite(_.random(-100, 960), _.random(450, 470), "minigames/roof/drop", true))
        drop.z = self.player.z + 1
        drop.alpha = _.random(.2, .6)
        drop.anim:setRandomFrame()
        drop.anim:getAnimation("idle"):onComplete(function()
            drop.alpha = _.random(.2, .6)
            drop.x     = self.camera.x - WIDTH / 2 + _.random(-100, 960)
            drop.y     = _.random(450, 470)
        end)
        self.rainDropList:add(drop)
    end

    self:fadeIn(3)
end

function GameManager:update(dt)
    GameManager.super.update(self, dt)

    self.shadowBig.x = self.camera.x - self.width / 2

    local value = self.thunder:getLightningValue()
    self.darknessOverlay.alpha = .4 * (1 - value)
    self.shadowBig.alpha = value
    if self.thunder.thunderLeft then
        self.player.imageLightningLeft.alpha = value
        self.player.imageLightningRight.alpha = 0
        -- self.player.shadowLong.alpha = value
        -- self.player.shadowLong.flip.x = true
        -- self.player.shadowLong.x = _.abs(self.player.shadowLong.x)
    else
        self.player.imageLightningRight.alpha = value
        self.player.imageLightningLeft.alpha = 0
        -- self.player.shadowLong.alpha = value
        -- self.player.shadowLong.flip.x = false
        -- self.player.shadowLong.x = -_.abs(self.player.shadowLong.x)
    end
end

function GameManager:showFlashback()
    self.currentFlashback = self.currentFlashback + 1
    local flashback = self.flashbacks[self.currentFlashback]
    if not flashback then return end
    flashback.visible = true
    flashback.alpha = 0
    self:tween(flashback, 1, { alpha = .8 })
        :after(1, { alpha = 0 })
        :delay(1.3)
end

return GameManager
