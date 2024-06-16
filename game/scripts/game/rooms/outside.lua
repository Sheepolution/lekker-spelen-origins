local Sprite = require "base.sprite"
local Rect = require "base.rect"
local Entity = require "base.entity"
local SFX = require "base.sfx"
local Scene = require "base.scene"

local Outside = Scene:extend("OutsideScene")

function Outside:new(x, y, mapLevel)
    Outside.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Outside:done()
    Outside.super.done(self)

    self.scene:prepareFightingGameTransition()

    self.scene.ambience:setDefaultVolume(.5)
    self.scene.ambience:play("wind", 3)

    self.cloud1 = self.mapLevel:add(Sprite(self.x, self.y + 378, "decoration/roof/cloud1"))
    self.cloud2 = self.mapLevel:add(Sprite(self.x, self.y + 378, "decoration/roof/cloud2"))

    self.clouds = list({ self.cloud1, self.cloud2 })
    self.clouds(function(e)
        e.solid = 0
        e.z = ZMAP.TileLayer + 1
    end)

    self.cloud1.speed = 40
    self.cloud2.speed = 85

    self.lightningSprite = self.mapLevel:add(Sprite(self.x + 280, self.y - 100, "decoration/roof/lightning"))
    self.lightningSprite.visible = false
    self.lightningSprite.z = ZMAP.TileLayer + 2

    self.background = self.mapLevel:add(Sprite(self.x, self.y, "decoration/roof/background"))
    self.background.startRGB = { 109, 197, 255 }
    self.background.darkRGB = { 25, 27, 45 }
    self.background:setColor(self.background.startRGB)
    self.background.z = ZMAP.TileLayer + 3

    self.darkness = 1;
    -- self:darker(0)

    self.darknessOverlay = self:addOverlay(Rect(0, 0, WIDTH, HEIGHT))
    self.darknessOverlay.alpha = 0
    self.darknessOverlay:setColor(0, 0, 0)
    self.darknessOverlay.z = ZMAP.TileLayer + 4
    self.z = ZMAP.TOP

    -- self:delay(4, self.wrap:lightning())

    self.rainList = list()

    for i = 1, 20 do
        local rain = self.mapLevel:add(Entity(self.x + _.random(-100, 960), self.y + _.random(-1000, -100),
            "decoration/roof/rain"))
        rain.z = ZMAP.TOP + 1
        rain.interactable = false
        rain.alpha = _.random(.5, 1)
        rain.solid = 0
        rain.removeOnLevelChange = true
        self.rainList:add(rain)
    end
end

function Outside:update(dt)
    self.clouds(function(cloud)
        cloud.offset.x = cloud.offset.x - cloud.speed * dt

        if cloud.offset.x < -cloud.width / 2 then
            cloud.offset.x = cloud.offset.x + cloud.width / 2
        end
    end)

    self.rainList(function(r)
        if r.y > self.mapLevel.y + self.mapLevel.height then
            r.y = self.mapLevel.y + _.random(-200, -300)
            r.x = self.mapLevel.x + _.random(-100, 960)
            r:moveDown(_.random(1200, 1450))
            r.alpha = _.random(.5, 1)
        end
    end)

    Outside.super.update(self, dt)
end

function Outside:darker(value, speed)
    -- TODO: Fix what happens when method is again called before tween is finished

    local start = self.background.startRGB
    local dark = self.background.darkRGB

    if self.darkenTween then
        self.darkenTween:stop()
    end

    self.darkenTween = self:tween(speed or 3, { darkness = value and (value) or self.darkness - (1 / 7) })
        :onupdate(function()
            self.clouds:setColor(25 + 230 * self.darkness, 25 + 230 * self.darkness, 25 + 230 * self.darkness)

            local r = start[1] - dark[1]
            local g = start[2] - dark[2]
            local b = start[3] - dark[3]

            self.background:setColor(
                dark[1] + r * self.darkness,
                dark[2] + g * self.darkness,
                dark[3] + b * self.darkness
            )

            self.darknessOverlay.alpha = .5 * (1 - self.darkness)
        end)
        :oncomplete(function() self.darkenTween = nil end)

    if not speed then
        self:tween(self.cloud1, 3, { speed = self.cloud1.speed + 15 })
        self:tween(self.cloud2, 3, { speed = self.cloud2.speed + 15 })
    end
end

function Outside:lightning()
    self.lightningSprite.visible = true
    self.scene:rumble(.5, .2)
    self:delay(.05, function()
        self.darkness = 1
        self.darknessOverlay.alpha = 0

        self.clouds:setColor(50 + 205 * self.darkness, 50 + 205 * self.darkness, 60 + 195 * self.darkness)

        self.background.startRGB = { 202, 206, 230 }
        self.background:setColor(self.background.startRGB)

        self:delay(.2, function()
            self:startRain()
            self.lightningSprite:setColor(255, 255, 255)
            self:tween(self.lightningSprite, .5, { alpha = 0 })
            self:darker(0, .5)
        end)
    end)
end

function Outside:startRain()
    self.scene.ambience:play("rain_wind", 3)
    self.rainList(function(rain)
        rain:moveDown(_.random(1200, 1450))
        rain:moveRight(_.random(180, 200))
    end)
end

return Outside
