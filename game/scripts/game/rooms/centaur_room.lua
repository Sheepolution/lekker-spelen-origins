local PeterOnTimon = require "characters.players.peter_on_timon"
local Centaur = require "bosses.centaur.centaur"
local Sprite = require "base.sprite"
local Rect = require "base.rect"
local FlagManager = require "flagmanager"
local Save = require "base.save"
local Peter = require "characters.players.peter"
local Timon = require "characters.players.timon"
local Telegate = require "interactables.telegate"
local Scene = require "base.scene"

local CentaurRoom = Scene:extend("CentaurRoom")

function CentaurRoom:new(x, y, mapLevel)
    CentaurRoom.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function CentaurRoom:done()
    self.background:add("flora/set/7", 22200, 416)
    self.background:add("flora/set/6", 22000, 447)
    self.background:add("vat_radioactief", 21530, 397)
    self.background:add("vat_radioactief", 21453, 269)
    self.background:add("vat_radioactief", 21671, 141)
    self.background:add("spinnenweb_rechts_l", 21648, 248)
    self.background:add("logo_labklein", 22555, 258)
    self.background:add("arrow_up", 9353, 406)
    self.background:add("arrow_up", 9659, 277)
    self.background:add("bordje_alert", 11776, 297)

    if FlagManager:get(Enums.Flag.defeatedCentaur) then
        return
    end

    self.centaur = self.mapLevel:add(Centaur(self.mapLevel.x + 138, self.mapLevel.y + 41), true)
    self.centaur.room = self
    self.centaurLegs = self.mapLevel:add(Sprite(self.mapLevel.x + 138, self.mapLevel.y + 41,
        "bosses/centaur/centaur_legs"))
    self.centaurLegs.z = ZMAP.Timon + 1
    self.largeLight = self.mapLevel:add(Rect(self.mapLevel.x + 3000, self.mapLevel.y + self.mapLevel.height / 2))
    self.scene:addLightSource(self.largeLight, 2000, 10000)

    if FlagManager:get(Enums.Flag.cutsceneCentaurIntro) then
        self:delay(.01, function()
            self:initializeRestart()
        end)
    end

    self:cb(function()
        local telegate = self.scene:findEntityWithTag("Telegate")

        if telegate then
            telegate.warpPlayersIn = function(t)
                self.scene.players:clear()

                local level = self.scene.map:getCurrentLevel()

                local timon = self.scene.timon
                self.scene.timon:destroy()

                self.scene.peter = level:addEntity(Peter(), true)
                self.scene.timon = level:addEntity(Timon(), true)

                self.scene.players:add(self.scene.peter)
                self.scene.players:add(self.scene.timon)

                self.scene.players:center(timon:center())

                self.scene.peter.healthMax = Save:get("game.health.peter.max")
                self.scene.timon.healthMax = Save:get("game.health.timon.max")

                self.scene.peter.health = Save:get("game.health.peter.current")
                self.scene.timon.health = Save:get("game.health.timon.current")

                self.scene.cameraFollow:center(self.scene.peter:center())
                self.scene:configurePlayerFollowing()

                Telegate.warpPlayersIn(t)
            end
        end
    end)
end

function CentaurRoom:update(dt)
    CentaurRoom.super.update(self, dt)

    if self.scene.timon and self.scene.timon.x > self.mapLevel.x + 3000 and not self.turnedOffLights then
        self.once:turnOffLights()
    end
end

function CentaurRoom:initializeRestart(first)
    self.scene:onInitializingBoss()

    self.centaurLegs:destroy()
    self:delay(1, function()
        self.centaur:startRunning()
    end)

    if not first then
        local level = self.scene:getLevel()
        self.scene.peter:destroy()
        self.scene.timon:destroy()
        self.scene.timon = level:add(PeterOnTimon(self.scene.peter:centerX(), self.scene.timon:centerY() - 5))
        self.scene.peter = nil
        self.scene.players:clear()
        self.scene.players:add(self.scene.timon)
        self.scene.camera:follow(self.scene.timon, true)
        self.scene.camera.lerp = 0
    end

    local music = self.scene.music:play("bosses/centaur/theme", nil, true)
    if music then
        music:setLooping(false)
    end
end

function CentaurRoom:onDefeatingCentaur()
    FlagManager:set(Enums.Flag.defeatedCentaur, true)
end

function CentaurRoom:turnOffLights()
    self:tween(self.scene.darkness, 1, { alpha = 0 })
        :oncomplete(function()
            if self.largeLight then
                self.largeLight:destroy()
            end
        end)
end

return CentaurRoom
