local Asset = require "base.asset"
local Sprite = require "base.sprite"
local Sicko = require "bosses.sicko.sicko"
local Blueprint = require "pickupables.blueprint"
local FlagManager = require "flagmanager"
local Save = require "base.save"
local Scene = require "base.scene"

local SickoRoom = Scene:extend("SickoRoom")

function SickoRoom:new(x, y, mapLevel)
    SickoRoom.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function SickoRoom:done()
    self.sicko = Sicko(self.mapLevel:centerX(), self.mapLevel:centerY() - 140)
    self.background = self.mapLevel:add(Sprite(self.x + 64, self.y + 56, "bosses/sicko/decoration/background"))
    self.background.z = 100
    self.setup = self.mapLevel:add(Sprite(self.x + 352, self.y + 354, "bosses/sicko/decoration/setup", true))
    self.setup.anim:set("no_sicko")
    self.setup.tag = "Setup"
    self.setup.z = 90

    if FlagManager:get(Enums.Flag.cutsceneSickoIntro) then
        self:initializeRestart()
    else
        self:initializeCutscene()
    end
end

function SickoRoom:update(dt)
    SickoRoom.super.update(self, dt)
    if self.video then
        if not self.video:isPlaying() then
            self.video:rewind()
            self.video:play()
        end
    end

    if self.sicko and self.sicko.died then
        if not self.scene:findEntityOfType(Blueprint) then
            self.scene.noDoorAccess = false
        end
    end
end

function SickoRoom:draw()
    SickoRoom.super.draw(self)
    if self.video then
        love.graphics.setColor(1, 1, 1, 1)
        local scaleX = 30 / self.video:getWidth()
        local scaleY = 22 / self.video:getHeight()

        love.graphics.setShader(self.videoShader)
        love.graphics.draw(self.video, self.videoPos.x, self.videoPos.y, 0, scaleX, scaleY)
        love.graphics.setShader()
    end
end

function SickoRoom:initializeRestart(first)
    if not first then
        self.mapLevel:add(self.sicko)
        self.sicko.room = self
        self.setup:setColor(100, 100, 100)
    else
        self.scene.peter.healthMax = Save:get("game.health.peter.max")
        self.scene.timon.healthMax = Save:get("game.health.timon.max")

        self.scene.peter.health = self.scene.peter.healthMax
        self.scene.timon.health = self.scene.timon.healthMax

        Save:set("game.health.peter.current", self.scene.peter.healthMax)
        Save:set("game.health.timon.current", self.scene.timon.healthMax)

        self.scene.ui:initHealth()

        self.video = nil
        self.setupColorValue = 255
        self:tween(.5, { setupColorValue = 100 })
            :onupdate(function()
                self.setup:setColor(self.setupColorValue, self.setupColorValue, self.setupColorValue)
            end)
    end

    self:delay(2.6, function()
        self.sicko:executeNextAttack(first)
    end)

    self.scene.music:play("bosses/sicko/theme", nil, true, 4.26)
    self.scene.music:setVolume(0.8, false, true)

    self.setup.anim:set("no_skateboard")
    self.scene.noDoorAccess = true
    self.scene:onInitializingBoss()

    self.scene:addShader("waves_area")
    self.scene:send("radius", 60)
    self.scene:send("curves", 20)
    self.scene:send("amount", .4)
    self.scene:send("speed", 4)

    self.scene.shaderUpdater = function(scene, dt)
        if scene.peter then
            local data = {}
            if scene.peter.drunk then
                table.insert(data, { scene.camera:toScreen(scene.peter:center()) })
            else
                table.insert(data, { -1000, -1000 })
            end

            if scene.timon.drunk then
                table.insert(data, { scene.camera:toScreen(scene.timon:center()) })
            else
                table.insert(data, { -1000, -1000 })
            end

            scene:send("circles", unpack(data))
        end
    end
end

function SickoRoom:initializeCutscene()
    self.videoKeesCo = Asset.video("bosses/sicko/decoration/kees_co")
    self.videoFriends = Asset.video("bosses/sicko/decoration/friends")
    self.videoRoss = Asset.video("bosses/sicko/decoration/ross")
    self.videoGTST = Asset.video("bosses/sicko/decoration/gtst")
    self.videoSpangas = Asset.video("bosses/sicko/decoration/spangas")
    self.videoZap = Asset.video("bosses/sicko/decoration/zap")
    self.video = self.videoKeesCo
    self.video:play()
    self.audio = Asset.audio("music/bosses/sicko/decoration/kees_co")
    self.audio:play()

    self.videoPos = {
        x = self.x + 479,
        y = self.y + 392
    }

    local main_event = Save:get("game.stats.main_event")

    self.scene:startCutscene("sicko_intro" .. (main_event == "timon" and "_timon" or ""))

    self.videoShader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            // Use VideoTexel
            texture_coords.x = floor(texture_coords.x*27)/(27);
            texture_coords.y = floor(texture_coords.y*20)/(20);
            vec4 finTex = VideoTexel(texture_coords);
            return finTex;
        }
    ]])
end

function SickoRoom:onSickoDefeated()
    self.scene.music:stop(1, true)

    self:delay(1, function()
        self.scene:startCutscene("sicko_boss_defeat")
    end)
end

return SickoRoom
