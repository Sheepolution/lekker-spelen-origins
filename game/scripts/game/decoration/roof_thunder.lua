local Rect = require "base.rect"
local Sprite = require "base.sprite"
local Entity = require "base.entity"
local SFX = require "base.sfx"
local Scene = require "base.scene"

local RoofThunder = Scene:extend("RoofThunder")

RoofThunder.SFX = {
    lightnigSoft = SFX("sfx/roof/lightning_soft", 2, { pitchRange = .1 }),
    lightnigHard = SFX("sfx/roof/lightning_hard", 2, { pitchRange = .1 }),
}

function RoofThunder:new()
    RoofThunder.super.new(self)

    self:setBackgroundImage("minigames/roof/background")

    self.lightningSprite = self:addUnderlay(Sprite(0, -200, "minigames/roof/lightning"))
    self.lightningSprite.visible = false
    self.lightningSprite.z = ZMAP.TileLayer + 5
    self.lightningSprite.scale:set(.75, .75)
    self.lightningSprite:setFilter("linear")

    self.cloud1 = self:addUnderlay(Entity(0, 0, "minigames/roof/cloud3_new"))
    self.cloud2 = self:addUnderlay(Entity(0, 40, "minigames/roof/cloud2_new"))
    self.cloud3 = self:addUnderlay(Entity(0, 70, "minigames/roof/cloud1_new"))
    self.cloud3.darkColor = { 42, 44, 68 }
    self.cloud3.lightningColor = { 237, 238, 245 }
    self.cloud2.darkColor = { 60, 63, 91 }
    self.cloud2.lightningColor = { 207, 209, 225 }
    self.cloud1.darkColor = { 89, 93, 127 }
    self.cloud1.lightningColor = { 169, 173, 200 }

    self.cloud1.z = ZMAP.TileLayer + 2
    self.cloud2.z = ZMAP.TileLayer + 3
    self.cloud3.z = ZMAP.TileLayer + 4
    self.clouds = list({ self.cloud1, self.cloud2, self.cloud3 })
    self.clouds(function(e)
        e.solid = 0
        e:setColor(e.darkColor)
    end)

    self.cloud1:moveRight(50)
    self.cloud2:moveRight(25)
    self.cloud3:moveRight(10)

    self.darknessOverlay = self:addOverlay(Rect(0, 0, 960, 540))
    self.darknessOverlay.alpha = .4
    self.darknessOverlay:setColor(0, 0, 0)

    self.lightningInterval = step.every(5, 9)

    self.lightningValue = 0

    self.background = {}
    self.background.lightningRGB = { 249, 251, 255 }
    self.background.darkRGB = { 25, 27, 45 }

    self.backgroundImage:setColor(self.background.darkRGB)

    self.rainList = list()

    self.lightningCount = 0

    self.stars = self:addUnderlay(Sprite(0, 0, "minigames/roof/stars"))
    self.stars.z = ZMAP.TileLayer + 5
    self.stars.alpha = 0
end

function RoofThunder:done()
    for i = 1, 60 do
        local rain = self.scene:addOverlay(Entity(_.random(-100, 960), _.random(-1000, -100), "minigames/roof/rain"))
        rain.z = ZMAP.TileLayer + 1
        rain.removeOnLevelChange = true
        rain.interactable = false
        rain.alpha = _.random(.2, .6)
        rain.solid = 0
        rain.rounding = false
        rain:moveDown(_.random(1200, 1650))
        rain:moveRight(_.random(180, 200))
        self.rainList:add(rain)
    end
end

function RoofThunder:update(dt)
    RoofThunder.super.update(self, dt)
    if self.cloud3.x > 0 then
        self.cloud3.x = self.cloud3.x - self.cloud3.width / 2
    end

    if self.cloud2.x > 0 then
        self.cloud2.x = self.cloud2.x - self.cloud2.width / 2
    end

    if self.cloud1.x > 0 then
        self.cloud1.x = self.cloud1.x - self.cloud1.width / 2
    end

    self.rainList:foreach(function(e)
        if e.y > 540 then
            e.y = _.random(-200, -300)
            e.x = _.random(-100, 960)
            local t = _.random(0, 1)
            e:moveDown(800 + 450 * t)
            e:moveRight(180 + 20 * t)
            e.alpha = .1 + .3 * t
            local r = .5 + .5 * t
            e.scale:set(r, r)
        end
    end)

    if self.lightningInterval(dt) then
        self:lightning()
    end
end

function RoofThunder:lightning()
    self.lightningCount = self.lightningCount + 1
    if not self.noLightningSFX then
        if self.lightningCount % 3 == 0 then
            RoofThunder.SFX.lightnigHard:play()
        else
            RoofThunder.SFX.lightnigSoft:play()
        end
    end

    local left = _.coin()
    self.thunderLeft = left
    self.lightningSprite.visible = true
    self.lightningSprite.alpha = 1

    self.lightningSprite:centerX(WIDTH / 2 + (left and -200 or 200))
    self.lightningSprite.flip.x = _.coin()

    self:delay(.05, function()
        self.darknessOverlay.alpha = 0
        self.lightningValue = 1

        self.clouds(function(e)
            e:setColor(e.lightningColor)
        end)

        self.backgroundImage:setColor(self.background.lightningRGB)

        self:tween(self, .5, { lightningValue = 0 }):onupdate(function()
            self.lightningSprite.alpha = self.lightningValue
            self.backgroundImage:setColor(self:getLightningColor(self.background.darkRGB, self.background.lightningRGB))

            self.clouds(function(e)
                e:setColor(self:getLightningColor(e.darkColor, e.lightningColor))
            end)

            self.darknessOverlay.alpha = .4 * (1 - self.lightningValue)
        end):delay(.5)
    end)
end

function RoofThunder:getLightningColor(darkColor, lightningColor)
    local value = self.lightningValue
    local r1, g1, b1 = unpack(darkColor)
    local r2, g2, b2 = unpack(lightningColor)

    local r = r1 + (r2 - r1) * value
    local g = g1 + (g2 - g1) * value
    local b = b1 + (b2 - b1) * value

    return { r, g, b }
end

function RoofThunder:getLightningValue()
    return self.lightningValue
end

function RoofThunder:setNoLightningSFX()
    self.noLightningSFX = true
end

function RoofThunder:showStars()
    self:tween(self.stars, 10, { alpha = .4 })
end

return RoofThunder
