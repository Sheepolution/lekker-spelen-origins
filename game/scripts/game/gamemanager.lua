local push = require("libs").push
local moonshine = require "libs.moonshine"
local Rect = require "base.rect"
local Save = require "base.save"
local Colors = require "base.colors"
local Camera = require "base.camera"
local MapUtils = require "base.map.maputils"
local Document = require "documents.document"
local DeathScreen = require "death_screen"
local UfoGame = require "minigames.ufo.gamemanager"
local FightingGame = require "minigames.fighter.gamemanager"
local SadRoof = require "minigames.roof.gamemanager"
local FlagManager = require "flagmanager"
local Log = require "documents.log"
local Blueprint = require "documents.blueprint"
local Charizard = require "documents.charizard"
local TransitionBars = require "transitions.bars"
local TransitionFight = require "transitions.fight"
local Peter = require "characters.players.peter"
local Timon = require "characters.players.timon"
local Textbox = require "textbox.textbox"
local LineDrawer = require "interactables.linedrawer"
local UI = require "ui"
local Darkness = require "darkness"
local Cutscene = require "cutscene"
local Menu = require "menu"
local Music = require "base.music"
local SFXManager = require "base.sfxmanager"
local Sprite = require "base.sprite"
local Player = require "characters.players.player"
local Text = require "base.text"
local Speech = require "speech"
local Ending = require "ending"
local Credits = require "credits.credits"
local SFX = require "base.sfx"
local Input = require "base.input"
local Scene = require "base.scene"

local GameManager = Scene:extend("GameManager")

Colors:add("peter", 213, 56, 65, 1)
Colors:add("timon", 64, 130, 229, 1)
-- Colors:add("timon", 94, 174, 244, 1)

-- Can't use enum because it is used in save data
-- MAYBE: Use enum and convert to key when saving
GameManager.CheckpointType = {
    Normal = "Normal",
    Door = "Door",
    Reviver = "Reviver",
    Warp = "Warp"
}

function GameManager:new(...)
    GameManager.super.new(self, ...)

    love.audio.stop()

    love.window.setFullscreen(Save:get("settings.screen.fullscreen"))
    push:applySettings({ pixelperfect = Save:get("settings.screen.pixelperfect") })
    push:applySettings({ vsync = Save:get("settings.screen.vsync") and 1 or 0 })
    push:setFilter(Save:get("settings.screen.sharp") and "nearest" or "linear")

    local max = (Save:get("settings.audio.master") / 100) * (Save:get("settings.audio.music") / 100)
    Music.updateMaxVolume(max)

    max = (Save:get("settings.audio.master") / 100) * (Save:get("settings.audio.sfx") / 100)
    SFX.updateMaxVolume(max)

    -- Preload joysticks to prevent lag mid game
    local joysticks = love.joystick.getJoysticks()
    for i, v in ipairs(joysticks) do
        v:getID()
        v:isVibrationSupported()
    end

    self:setBackgroundColor(14, 18, 26, 255)

    self:setMap("map", nil, {
        zmap = {
            98,
            0,
            99,
            0,
            100
        },
        separateTileLayers = {
            Fake = {
                properties = {
                    z = ZMAP.FakeTileLayer,
                    decoration = true,
                }
            },
            FakeBorder = {
                properties = {
                    z = ZMAP.FakeTileLayer
                }
            }
        }
    })

    self.initialLevelChange = true
    self.map.useTransition = true

    -- Transition
    self.doorTransition = false
    self.transitionBars = self:addOverlay(TransitionBars())

    -- Overlay
    self.textbox = self:addOverlay(Textbox())
    self.ui = self:addOverlay(UI())
    self.ui:init()
    self.darkenGameRect = self:addOverlay(Rect(0, 0, WIDTH, HEIGHT))
    self.darkenGameRect:setColor(0, 0, 0)
    self.darkenGameRect.alpha = 0
    self.darkenGameRect.z = ZMAP.DarkenGameRect

    -- Player dying
    self.inDeathAnimation = false
    self.deathScreen = self:addOverlay(DeathScreen())
    self.deathScreenDefault = DeathScreen
    self.deathCounterPeter = 0
    self.deathCounterTimon = 0
    self.playerDeathDelay = step.after(.1)

    -- Cutscenes
    self.preparedCutscenes = {}
    self.cutsceneBlackBarTop = self:addOverlay(Rect(0, -35, WIDTH, 35))
    self.cutsceneBlackBarBottom = self:addOverlay(Rect(0, HEIGHT, WIDTH, 35))
    self.cutsceneBlackBarTop:setColor(0, 0, 0)
    self.cutsceneBlackBarBottom:setColor(0, 0, 0)
    self.cutsceneBlackBarTop.z = ZMAP.Textbox + 1
    self.cutsceneBlackBarBottom.z = ZMAP.Textbox + 1

    self.hideDocumentDelay = step.after(1)

    self.totalGameTimerStep = step.every(1)

    self.saveIcon = self:addOverlay(Sprite(WIDTH - 56, HEIGHT - 56, "save"))
    self.saveIcon.z = -201
    self.saveIcon.alpha = 0

    -- Computer
    -- TODO: Move this to a separate function or something?
    self:addShader("spinsucker")
    self.suckDirection = 1
    self.spinSuckAmount = 0
    self:setShader()

    self.music = Music("music")
    self.ambience = Music("ambience")
    self.sfx = SFXManager("sfx")
    self.sfx:createEffect("reverb", { type = "reverb", decaytime = 1.2 })

    -- Camera
    self.cameraPeter = Camera(0, 0, WIDTH, HEIGHT)
    self.cameraTimon = Camera(0, 0, WIDTH, HEIGHT)
    self.camera.lerp = CAMERA_LERP

    self.darkness = self:addOverlay(Darkness(self.camera))

    -- Level
    self.pickupablesToBePermanentlyDestroyed = list()

    -- Line drawer
    self.lineDrawer = self:add(LineDrawer())

    self.players = list()

    self.cameraFollow = Rect(0, 0, 1, 1)

    self.camera.flooring = true

    self.inMenu = true
    self.goingToMainMenu = false

    if DEBUG then
        if false then
            -- self:addOverlay(Cutscene("peter", self.F:startRoofScene("peter")))
            -- self:startRoofScene("peter")
            -- self:goToEnding()
            -- self:goToCredits()
            -- self:goToSpeech()
            -- self:startWakuMinigame()
            -- self:toFightingGame(false, false)
            self:toUfoGame({ 7 })
        else
            self.map:toLevel("Start", true, false)
            local start = self:findEntityWithTag("StartScene")
            if start then
                self.menu = self:addOverlay(Menu(false, self))
            else
                self.inMenu = false
            end
        end
    else
        self.inMenu = true
        self.map:toLevel("Start", true, false)
        self.menu = self:addOverlay(Menu(false, self))
    end

    -- local level = self.map:getCurrentLevel()

    -- self.canvas = love.graphics.newCanvas(level.width, level.height)
    -- self.canvas:setFilter(CONFIG.defaultGraphicsFilter, CONFIG.defaultGraphicsFilter)
    -- self.image = self.canvas

    -- self.camera:setWindow(0, 0, level.width, level.height)

    -- Players

    self.peter = self.players:add(self:findEntityOfType(Peter))
    self.timon = self.players:add(self:findEntityOfType(Timon))

    if self.peter and self.timon then
        self.peter:setSidekick(self.timon)
        self.timon:setSidekick(self.peter)
    end

    if self.peter then
        self.peter.mapUnloadProtection = MapUtils.ProtectionLevel.Strong
        self.timon.mapUnloadProtection = MapUtils.ProtectionLevel.Strong
    end

    -- Camera
    self.splitScreen = false
    self.cameraPeter:setWindow(10, 10, WIDTH / 2 - 20, HEIGHT)
    self.cameraPeter:follow(self.peter)

    self.cameraTimon:setWindow(WIDTH / 2 + 10, 10, WIDTH / 2 - 20, HEIGHT)
    self.cameraTimon:follow(self.timon)

    self.splitScreenCooldown = step.during(.5)

    if self.peter then
        self.map:follow()

        self.camera.lerp = CAMERA_LERP
        self.camera:moveToPoint(WIDTH / 2, HEIGHT / 2)
        self.camera:follow(self.cameraFollow, true)
    end

    self.splitscreenBorder = self:addOverlay(Sprite(0, 0, "splitscreen_border", true))
        :setProperties({ z = 500, visible = false })

    -- self:delay(.1, function() self:toFightingGame() end)
    -- self:delay(.1, function() self:toUfoGame({ 8 }) end)

    self.inPauseMenu = false

    -- self:addShader("rgb")
    -- self:send("rgb_amount", 0.3)
    -- self.camera:zoomTo(.1)

    -- self.camera:zoomTo(.2)
    self.useStencil = true

    -- self.camera = nil
    -- self.savedTheLevel = false

    self.notificationText = self:addOverlay(Text(0, 0, "", 32))
    self.notificationText:center(WIDTH / 2, HEIGHT / 2)
    self.notificationText:setAlign("center", WIDTH)
    self.notificationText.alpha = 0
    self.notificationText.z = ZMAP.Document

    self.canPauseTheGame = true

    -- self:fadeIn(nil, nil, false)
end

function GameManager:update(dt)
    if self.ambience:isPlaying() then
        self.ambience:update(dt)
    end

    if self.showScene then
        GameManager.super.update(self, dt)
        return
    end

    if self.inPauseMenu then
        if self.goingToMainMenu then
            GameManager.super.update(self, dt)
            return
        end
        self.pauseMenu:update(dt)
        return
    end

    if self.inCutscene and not self.ufoGame and not self.roofEvent then
        local t = dt
        if self.peter then
            if Input:isDown(self.peter.keys[self.peter.controllerId].back) then
                dt = t * 4
            end
        end

        if self.timon then
            if Input:isDown(self.timon.keys[self.timon.controllerId].back) then
                dt = t * 4
            end
        end
    end

    if not self.inMenu then
        if not Save:get("game.beatGame") then
            if self.totalGameTimerStep(dt) then
                Save:increase("game.stats.time")
            end
        end
    end

    if self.inWater then
        self.waterWavesTimer = self.waterWavesTimer + 0.1 * dt
        self.effectsCamera.waves.time = self.waterWavesTimer
    end

    if not self.peter or (not self.peter.died and (not self.timon or not self.timon.died)) then
        if Input:isPressed(Player.keys[1].menu) or Input:isPressed(Player.keys[2].menu) then
            -- if self.showingNotification then
            --     self:hideNotification()
            --     return
            -- end

            if self.inUfoMinigame then
                self.inUfoMinigame = false
                self:fadeOut(.5, function()
                    if self.ufoGame then
                        self.ufoGame:destroy()
                    end

                    self.ufoGame = nil
                    self.menu:appear()
                    self:fadeIn(.5)
                end)
                return
            end

            if not self.inMenu and self.fadeRect.alpha == 0 then
                if self.canPauseTheGame then
                    self:createPauseMenu()
                end
            end
        end
    end

    if self.hideDocumentDelay(dt) then
        if Input:isPressed(Player.keys[1].confirm) or Input:isPressed(Timon.keys[2].confirm) then
            if self.currentDocument then
                self:hideDocument()
            elseif self.showingNotification then
                self:hideNotification()
            end
        end
    end

    -- TODO: Move this to a separate function
    if self.shader == "spinsucker" then
        self.spinSuckAmount = self.spinSuckAmount + dt * (self.spinSuckAmount * .5 + .1) * self.suckDirection
        self.spinSuckAmount = _.clamp(self.spinSuckAmount, 0, 1)
        self:send("amount", self.spinSuckAmount)
    end

    -- if self.checkpoint and self.checkpoint.type == GameManager.CheckpointType.Reviver then
    --     if Input:isPressed("k") then
    --         local entity = self:findEntity(function(e) return e.mapEntityId == self.checkpoint.mapEntityId end)
    --         self.players:teleportToCheckpoint(entity)
    --         -- self.players:foreach(function(e)
    --         --     e:center(entity:center())
    --         -- end)
    --     end
    -- end

    self:updateShader(dt)

    GameManager.super.update(self, dt)
end

function GameManager:drawInCamera()
    GameManager.super.drawInCamera(self)
    self:drawPlayerSniffing()
end

function GameManager:drawPlayerSniffing()
    for i, player in ipairs(self.players) do
        if player.canSniff and player.SM:is(player.MS.Sniff) then
            local max = player.sniffRadiusMax
            local alpha = 1 - _.clamp(player.sniffRadius / max, 0, 1)
            love.graphics.setColor(1, 1, 1, alpha)
            local x, y = player:getSniffPosition()
            love.graphics.circle("line", x, y,
                player.sniffRadius)
        end
    end
end

function GameManager:drawInCanvas()
    if self.splitScreen and not self.inDeathAnimation then
        self:drawSplitScreen()
        return
    end

    GameManager.super.drawInCanvas(self)
end

function GameManager:draw()
    GameManager.super.draw(self)

    -- FINAL: TURN THIS OFF
    -- if not self.savedTheLevel then
    --     local imageData = self.canvas:newImageData()
    --     imageData:encode("png", self.map:getCurrentLevel().id .. ".png")
    --     self.savedTheLevel = true
    -- end
end

function GameManager:drawSplitScreen()
    if self.showEffects and self.effectsCamera then
        self.effectsCamera(function()
            love.graphics.setColor(1, 1, 1, 1)
            self.cameraPeter:draw(function()
                self:drawInCamera()
            end)

            love.graphics.setColor(1, 1, 1, 1)
            self.cameraTimon:draw(function()
                self:drawInCamera()
            end)
        end)
    else
        love.graphics.setColor(1, 1, 1, 1)
        self.cameraPeter:draw(function()
            self:drawInCamera()
        end)

        love.graphics.setColor(1, 1, 1, 1)
        self.cameraTimon:draw(function()
            self:drawInCamera()
        end)
    end

    local camera = self.camera
    self.camera = nil
    GameManager.super.drawInCanvas(self)
    self.camera = camera
end

function GameManager:configurePlayerFollowing()
    self.peter:setSidekick(self.timon)
    self.timon:setSidekick(self.peter)

    self.peter.mapUnloadProtection = MapUtils.ProtectionLevel.Strong
    self.timon.mapUnloadProtection = MapUtils.ProtectionLevel.Strong

    self.map:follow()
    self.camera:follow(self.cameraFollow, true)
    self.cameraPeter:follow(self.peter)
    self.cameraTimon:follow(self.timon)
end

function GameManager:addLightSource(parent, radiusX, radiusY, overlay)
    return self.darkness:addLightSource(parent, radiusX, radiusY, overlay)
end

function GameManager:updateEntities(dt)
    if not self:canUpdateEntities() then
        return
    end

    GameManager.super.updateEntities(self, dt)

    self:checkIfPlayerDied(dt)
end

function GameManager:canUpdateEntities()
    return not self.inDeathAnimation
        and not self.currentDocument
        and not self.inPauseMenu
        and not self.showingNotification
end

function GameManager:checkIfPlayerDied(dt)
    if (self.peter and self.peter.died) or (self.timon and self.timon.died) then
        if self.playerDeathDelay(dt) then
            if self.peter and self.peter.died then
                self:onPlayerDying(self.timon.died and "both" or self.peter)
            elseif self.timon and self.timon.died then
                self:onPlayerDying(self.timon)
            end
            self.playerDeathDelay()
        end
    end
end

function GameManager:updateCamera(dt)
    if self.inDeathAnimation then return end

    if self.peter and self.timon then
        local px, py = self.peter:center()
        local tx, ty = self.timon:center()
        local distance_x = _.abs(px - tx)
        local distance_y = _.abs(py - ty)

        if distance_x > WIDTH - 100
            or distance_y > HEIGHT - 100 then
            if not self.splitScreen then
                if distance_x > distance_y then
                    self.splitscreenBorder.anim:set("horizontal")
                    if self.peter.x < self.timon.x then
                        self.cameraPeter:setWindow(10, 10, WIDTH / 2 - 20, HEIGHT)
                        self.cameraTimon:setWindow(WIDTH / 2 + 10, 10, WIDTH / 2 - 20, HEIGHT)
                    else
                        self.cameraPeter:setWindow(WIDTH / 2 + 10, 10, WIDTH / 2 - 20, HEIGHT)
                        self.cameraTimon:setWindow(10, 10, WIDTH / 2 - 20, HEIGHT)
                    end
                else
                    self.splitscreenBorder.anim:set("vertical")
                    if self.peter.y < self.timon.y then
                        self.cameraPeter:setWindow(10, 10, WIDTH, HEIGHT / 2 - 20)
                        self.cameraTimon:setWindow(10, HEIGHT / 2 + 10, WIDTH, HEIGHT / 2 - 20)
                    else
                        self.cameraPeter:setWindow(10, HEIGHT / 2 + 10, WIDTH, HEIGHT / 2 - 20)
                        self.cameraTimon:setWindow(10, 10, WIDTH, HEIGHT / 2 - 20)
                    end
                end

                self.splitscreenBorder.visible = true
                self.splitScreen = true
                self.splitScreenCooldown()
            end
        else
            if not self.splitScreenCooldown(dt) then
                self.splitscreenBorder.visible = false
                self.splitScreen = false
            end
        end

        local x = (px + tx) / 2
        local y = (py + ty) / 2
        self.cameraFollow:set(_.floor(x), _.floor(y))
        self.cameraPeter:update(dt)
        self.cameraTimon:update(dt)
    elseif self.peter then
        self.cameraFollow:set(self.peter:center())
        self.cameraPeter:update(dt)
    elseif self.timon then
        self.cameraFollow:set(self.timon:center())
        self.cameraTimon:update(dt)
    end

    GameManager.super.updateCamera(self, dt)
end

function GameManager:startCutscene(cutsceneName, onComplete, force)
    self.cutscene = require("data.cutscenes." .. cutsceneName)

    if self.cutscene.flag and FlagManager:get(self.cutscene.flag) and not force then
        self.cutscene = nil
        return
    end

    self.inCutscene = true

    self.players:goIntoCutscene()

    self:showCutsceneBars()

    self.ui:hide()

    if self.cutscenePausesMusic then
        self.music:pause(1)
    end

    if self.cutscene.functions and self.cutscene.functions.init then
        self:event(function() self.cutscene.functions.init(self) end, nil, 1, onComplete)
    end
end

function GameManager:prepareCutscene(cutsceneName, level, room)
    self.preparedCutscenes[level] = cutsceneName
    self.preparedRoom = room

    local cutscene = require("data.cutscenes." .. cutsceneName)
    if cutscene.flag and FlagManager:get(cutscene.flag) then
        return
    end

    if cutscene.functions.prepare then
        cutscene.functions.prepare(self)
    end
end

function GameManager:executeCutsceneFunction(functionName)
    self:event(function() self.cutscene.functions[functionName](self) end, nil, 1)
end

function GameManager:startDialogue(dialogueName, onComplete)
    local cb = self.coil.callback()

    if onComplete then
        local oldOnComplete = onComplete
        onComplete = function()
            oldOnComplete()
            cb()
        end
    else
        onComplete = cb
    end

    self.textbox:appear(self.cutscene.dialogues[dialogueName], onComplete)
    self.coil.wait(cb)
end

function GameManager:onEndCutscene(noMusicResume, fake)
    if not fake then
        if self.cutscene.flag then
            FlagManager:set(self.cutscene.flag, true)
        end
    end

    self.players:goOutOfCutscene()

    self.inCutscene = false

    self:hideCutsceneBars()
    self.ui:show()

    if self.preparedRoom then
        if self.preparedRoom.onEndCutscene then
            self.preparedRoom:onEndCutscene()
        end
        self.preparedRoom = nil
    end

    self.cutscene = nil
    self.cutsceneData = nil

    if self.musicCallbackAfterCutscene then
        self.musicCallbackAfterCutscene()
        self.musicCallbackAfterCutscene = nil
    elseif not noMusicResume then
        self.music:resume(1)
    end
end

function GameManager:showCutsceneBars()
    self:tween(self.cutsceneBlackBarTop, .5, { y = 0 })
    self:tween(self.cutsceneBlackBarBottom, .5, { y = HEIGHT - self.cutsceneBlackBarBottom.height })
end

function GameManager:hideCutsceneBars()
    self:tween(self.cutsceneBlackBarTop, .5, { y = -self.cutsceneBlackBarTop.height })
    self:tween(self.cutsceneBlackBarBottom, .5, { y = HEIGHT })
end

function GameManager:spawnPeter(x, y)
    self.peter = Peter()
    self.peter:center(x, y)
    self:getLevel():add(self.peter)
    self.players:add(self.peter)
    if self.timon then
        self.timon:setSidekick(self.peter)
        self.peter:setSidekick(self.timon)
    end

    local ability = Save:get("game.ability")
    if ability then
        -- Cut everything after underscore
        ability = ability:match("([^_]+)")

        self.peter.ability = self.peter.Ability[ability]
    end

    return self.peter
end

function GameManager:spawnTimon(x, y)
    self.timon = Timon()
    self.timon:center(x, y)
    self:getLevel():add(self.timon)
    self.players:add(self.timon)

    if self.peter then
        self.peter:setSidekick(self.timon)
        self.timon:setSidekick(self.peter)
    end

    local ability = Save:get("game.ability")
    if ability then
        -- Cut everything after underscore
        ability = ability:match("([^_]+)")

        self.timon.ability = self.timon.Ability[ability]
    end

    return self.timon
end

function GameManager:onChangingLevel(level)
    GameManager.super.onChangingLevel(self, level)

    self.inBossFight = false
    self.darkness:setDarkness(0)
    self.lineDrawer:clear()
    self.cutscenePausesMusic = true
    self.music:setVolume(self.music:getDefaultVolume(), 1)

    Save:save("game.stats.time")

    if self.players then
        self.players:clearSafePositions()
    end

    if self.room and self.room.music then
        self.room.music:destroy()
    end

    local room = self:findEntityWithTag("RoomManager")
    local music = self:findEntityWithTag("MusicManager")

    if self.warpingToLevel then
        self:moveCameraToLevel(level)
        self:onLevelWarp(level)
        if room then
            room:init()
        end

        if music then
            music:init()
        end
        return
    end

    self:moveCameraToLevel(level)

    if not self.restarting then
        if room then
            room:init()
        end

        if music then
            music:init()
        end
    end

    if self.initialLevelChange then
        self.initialLevelChange = false
        return
    end

    if self.doorTransition then
        self:finishDoorTransition(level)
        self:delay(.2, function()
            self.transitionBars:finish(self.doorTransitionLeft)
        end)
    elseif self.waterTransition then
        self.map:follow(self.cameraFollow)
        if self.waterTransition == "in" then
            -- self:goIntoWater()
            self:fadeIn(1, function()
                self.players(function(e) e.inCutscene = false end)
                self.waterTransition = false
            end, false)
        else
            self:goOutWater()
            self:fadeIn(1, function()
                self.players(function(e) e.inCutscene = false end)
                self.waterTransition = false
            end, false)
        end
    end
end

function GameManager:moveCameraToLevel(level)
    local x, y, w, h = level.x, level.y, level.width, level.height - 36
    self.camera:setWorld(x, y, w, h)
    self.cameraPeter:setWorld(x, y, w, h)
    self.cameraTimon:setWorld(x, y, w, h)
end

function GameManager:getPlayers()
    return self.players:copy()
end

function GameManager:findNearestPlayer(e)
    if self.timon and not self.peter then
        return self.timon, self.timon:getDistance(e)
    end

    if not self.peter then return end

    local peterDistance = self.peter:getDistance(e)
    local timonDistance = self.timon:getDistance(e)

    if peterDistance < timonDistance then
        return self.peter, peterDistance
    else
        return self.timon, timonDistance
    end
end

function GameManager:forceEnterDoor(doorLeft)
    if self.doorTransition then return end

    self.doorTransition = true
    self.doorTransitionLeft = doorLeft

    self.players:goIntoCutscene()

    self.map:follow(self.cameraFollow)

    if doorLeft then
        self.players:cutsceneWalkTo(-200, true)
    else
        self.players:cutsceneWalkTo(200, true)
    end
end

function GameManager:finishDoorTransition(level)
    if not self.doorTransition then return end
    local preparedCutscene = self.preparedCutscenes[level]
    local executedPrepared = false

    local cutscene, flagChecked

    if preparedCutscene then
        cutscene = require("data.cutscenes." .. preparedCutscene)
        flagChecked = cutscene.flag and FlagManager:get(cutscene.flag)
    end

    local callback = function(e)
        self.doorTransition = false
        e:setPermanentSafePosition()

        if preparedCutscene and not flagChecked then
            if not executedPrepared then
                executedPrepared = true
                self.preparedCutscenes[level] = nil
                self:startCutscene(preparedCutscene)

                local entity = self:findEntity(function(d) return d.mapEntityId == self.checkpoint.mapEntityId end)
                if entity and entity.tag == "Door" then
                    entity.cutsceneDoor = true
                end
            end
        else
            e.inCutscene = false
        end
    end

    local walk_distance = 140

    self.players:foreach(function(e)
        e.inputHoldingDown = false
        e.SM:unlock(e.MS.Walk)
        self:delay(.2, function()
            e.useGravity = true
        end)
    end)

    if self.doorTransitionLeft then
        self.players:centerX(level.x + level.width - 5)

        if self.peter then
            self.peter:cutsceneWalkTo(-walk_distance + 10, true, callback)
        end

        if self.timon then
            self.timon:cutsceneWalkTo(-walk_distance, true, callback)
        end
    else
        self.players:centerX(level.x + 5)

        if self.peter then
            self.peter:cutsceneWalkTo(walk_distance - 10, true, callback)
        end

        if self.timon then
            self.timon:cutsceneWalkTo(walk_distance, true, callback)
        end
    end

    self.players:teleport()
    self.players:destroyHoldingItem()
    self.map:follow()
end

function GameManager:showDocument(name, type, cutscene)
    if cutscene then
        self:initCoil()
        self.cutsceneCallback = self.coil:callback()
    end

    local document
    if type == Document.DocumentType.Log then
        document = self:addOverlay(Log(name))
    elseif type == Document.DocumentType.Blueprint then
        document = self:addOverlay(Blueprint(name))
    elseif type == Document.DocumentType.Charizard then
        document = self:addOverlay(Charizard())
    end

    self.currentDocument = document

    self.hideDocumentDelay()

    if not self.cutscene and not cutscene then
        self.music:setVolume(.25, .5)
    end

    -- Tween document to center
    document.y = HEIGHT
    self:tween(document, .25, { y = HEIGHT / 2 - document.height / 2 })

    self:tween(self.darkenGameRect, .25, { alpha = .5 })

    if cutscene then
        self.coil.wait(self.cutsceneCallback)
    end
end

function GameManager:hideDocument(force)
    if not self.currentDocument then return end
    if self.currentDocument.special and not force then return end

    local sprite = self.currentDocument

    -- Tween document to center
    self:tween(sprite, .25, { y = HEIGHT }):oncomplete(function()
        sprite:destroy()
    end)

    self:tween(self.darkenGameRect, .25, { alpha = 0 })

    if self.currentDocument.log and self.currentDocument.log.cutscene then
        self.cutscenePausesMusic = false
        self:startCutscene(self.currentDocument.log.cutscene)
    elseif self.currentDocument.charizard then
        self.cutscenePausesMusic = false
        self:startCutscene("charizard")
    else
        self.music:setVolume(self.music:getDefaultVolume(), .5)
    end

    if self.cutsceneCallback then
        self.cutsceneCallback()
        self.cutsceneCallback = nil
    end

    if self.currentDocument.tag == "Blueprint" then
        if self.currentDocument.name == "S1-KO" then
            self:delay(1,
                function()
                    self.noDoorAccess = false
                    local minigame = Save:get("minigames.fighter")
                    if not minigame then
                        Save:save("minigames.fighter", true)
                        self:showNotification(
                            "PETER vs TIMON unlocked!\n\nJe kan vanuit het hoofdmenu nu\nPETER vs TIMON selecteren!\n\nRematch?")
                    end
                end)
        else
            if #Save:get("documents.blueprints") == 1 then
                self:delay(1,
                    self.F:showNotification(
                        "Blauwdrukken unlocked!\n\nJe kan nu opgepakte blauwdrukken opnieuw bekijken in het menu.\nVerzamel ze allemaal!"))
            end
        end
    end

    self.currentDocument = nil
end

function GameManager:startSucking()
    self:setShader("spinsucker")
    self.spinSuckAmount = 0.0001
    self.suckDirection = 1
    self:send("amount", 0)
end

function GameManager:prepareFightingGameTransition()
    self.transitionFight = self:addOverlay(TransitionFight())
end

function GameManager:toFightingGame(minigame, training)
    if minigame then
        self.inFightingMinigame = true
        self.music:stop(.5)
    else
        self.roofEvent = true
    end
    if not self.transitionFight then
        self:prepareFightingGameTransition()
    end

    self.transitionFight:start(function()
        self:fadeOut(1, function()
            self.players:destroy()
            self.peter = nil
            self.timon = nil
            self.transitionFight:destroy()
            self.transitionFight = nil
            self.map:toLevel("Empty", true, false)
            self.fightingGame = self:addOverlay(FightingGame(training))

            if minigame then
                self.music:stop()
                self.menu:destroy()
                self.inMenu = false
            end

            self:fadeIn(1, nil, false)
        end)
    end, minigame)
end

function GameManager:onFightingGameWin(tag)
    self.fightingGame = nil
    if self.inFightingMinigame then
        self:toMainMenu()
        return
    end


    self:addOverlay(Cutscene(tag:lower(), self.F:startRoofScene(tag)))
    self:fadeIn(1)
end

function GameManager:toUfoGame(levelsToBeat, callback, minigame)
    if self.ufoGame then return end
    self.beatingUfoGameCallback = callback
    self:fadeOut(1, function()
        self.inUfoMinigame = minigame
        self.music:stop()
        self.ufoGame = self:addOverlay(UfoGame(levelsToBeat, minigame))
        self:setShader()
        self:fadeIn()
    end)
end

function GameManager:onBeatingUfoGame()
    self:setShader("spinsucker")
    self.ufoGame = nil
    self.suckDirection = -1
    self:fadeIn(1, self.beatingUfoGameCallback, function()
        self:setShader()
    end)
end

function GameManager:warpToLevel(level)
    -- HACK
    self:delay(.1, function()
        self.warpingToLevel = level
        self.map:toLevel(level, true, false)
        self:fadeIn(1)
    end)
end

function GameManager:onLevelWarp(level, nofollow)
    self.warpingToLevel = nil
    local telegate = level.entities:find(function(e)
        return e.tag == "Telegate"
    end)

    local abilityMap = {
        ["Central_hub"] = "Teleport",
        ["Konkie_start"] = "Shoot",
        ["Horsey_start"] = "Clone",
        ["Horror_start"] = "Light"
    }

    self:clearCache()

    local ability = abilityMap[level.id]

    telegate:warpPlayersOut(function()
        local currentLevel = self.map:getCurrentLevel()
        local preparedCutscene = self.preparedCutscenes[currentLevel]
        if preparedCutscene then
            self.preparedCutscenes[currentLevel] = nil
            self:delay(1, self.F:startCutscene(preparedCutscene))
        end

        self.players:foreach(function(e)
            e.inControl = true
            e.hurtable = true
            e.inCutscene = preparedCutscene ~= nil
            if ability then
                e.ability = e.Ability[ability]
            else
                e.ability = nil
            end
        end)

        Save:set("game.ability", ability)
    end)

    self.camera.lerp = CAMERA_LERP

    if not nofollow then
        self.cameraFollow:center(telegate:center())
        self.camera:moveToPoint(telegate:center())
        self.camera:follow(self.cameraFollow)
    end

    self:onReachingCheckpoint(telegate)
end

function GameManager:onPlayerDying(player)
    if self.inDeathAnimation then return end
    self.inDeathAnimation = true

    if self:getLevel().id == "Konkie_boss" then
        local t = { p = 1 }
        local song = self.music:getSong()
        self:tween(t, 3, { p = 0.001 })
            :onupdate(function() song:setPitch(t.p) end)
            :oncomplete(function()
                self.music:stop()
                song:setPitch(1)
            end)

        if player == "both" then
            Save:increase("game.deaths.peter", 1, true)
            Save:increase("game.deaths.timon", 1, true)
        else
            Save:increase("game.deaths." .. player.tag:lower(), 1, true)
        end
    elseif player == "both" then
        Save:increase("game.deaths.peter", 1, true)
        Save:increase("game.deaths.timon", 1, true)
        self.music:play("death/both"):setLooping(false)
    else
        Save:increase("game.deaths." .. player.tag:lower(), 1, true)
        self.music:play("death/" .. player.tag:lower()):setLooping(false)
    end

    Save:save("game.stats.time")

    self.deathScreen:onPlayerDying(
        player == "both" and self.peter or player,
        player == "both" and self.timon or nil
    )

    self.sfx:stop()

    -- TODO: Move this to a separate function
    self:delay(self.deathScreen:getFadeDelay(), self.F:fadeOut(.5, self.F:restartLevel()))
end

function GameManager:restartLevel(level)
    self.spatialHash = {}

    self.pickupablesToBePermanentlyDestroyed:clear()
    level = level or self.map:getCurrentLevel().id

    if self.peter then
        self.peter:destroy()
        self.timon:destroy()
    end

    self.splitScreen = false

    self.restarting = true

    self.map:toLevel(level, true, false)

    level = self.map:getCurrentLevel()

    self.peter = level:addEntity(Peter(), true)
    self.timon = level:addEntity(Timon(), true)

    local ability = Save:get("game.ability")
    if ability then
        -- Cut everything after underscore
        ability = ability:match("([^_]+)")

        self.peter.ability = self.peter.Ability[ability]
        self.timon.ability = self.timon.Ability[ability]
    end

    self.players:clear()

    self.players:add(self.peter)
    self.players:add(self.timon)

    self.peter.healthMax = Save:get("game.health.peter.max")
    self.timon.healthMax = Save:get("game.health.timon.max")

    self.peter.health = self.peter.healthMax
    self.timon.health = self.timon.healthMax

    Save:set("game.health.peter.current", self.peter.healthMax)
    Save:set("game.health.timon.current", self.timon.healthMax)

    Save:restore("game.euro")
    Save:restore("game.stats.euro")

    self.ui:init()
    if not self.inMenu then
        self.ui:show()
    end

    self:configurePlayerFollowing()

    self.dyingPlayers = nil
    self.inDeathAnimation = false
    self.deathScreen.visible = false
    self:fadeIn(.5, nil, false)

    local room = self:findEntityWithTag("RoomManager")
    local music = self:findEntityWithTag("MusicManager")

    if self.checkpoint.type == GameManager.CheckpointType.Door then
        self.doorTransition = true
    end

    if room then
        room:init()
    end

    if music then
        music:init()
    end

    if level.id ~= "Konkie_cart" then
        self:placePlayersAtLastCheckpoint()
    else
        self.peter.inControl = false
        self.timon.inControl = false
        self.peter:destroy()
        self.timon:destroy()
        self.peter = nil
        self.timon = nil
        self.players:clear()
    end

    -- NOTE: If there are bugs it's because this was placed below the above if-else
    -- Up to here

    -- NOTE: Turning this on might break central hub cutscenes. Needs testing.
    -- local preparedCutscene = self.preparedCutscenes[level]
    -- self.preparedCutscenes[level] = nil
    -- self:startCutscene(preparedCutscene)

    self.restarting = false
end

function GameManager:placePlayersAtLastCheckpoint()
    if self.map:getCurrentLevel().id ~= self.checkpoint.level then
        self.map:toLevel(self.checkpoint.level, false, false)
        return
    end

    local checkpointEntity = self:findEntity(function(e)
        return e.mapEntityId == self.checkpoint.mapEntityId
    end)

    if not checkpointEntity then
        return
    end

    self.peter:bottom(checkpointEntity:bottom())
    self.timon:bottom(checkpointEntity:bottom())

    if self.checkpoint.type == GameManager.CheckpointType.Door then
        self.peter.inCutscene = true
        self.timon.inCutscene = true
        self.doorTransition = true
        self.doorTransitionLeft = not checkpointEntity.flipped
        self:finishDoorTransition(self.map:getCurrentLevel())
    elseif self.checkpoint.type == GameManager.CheckpointType.Warp then
        self.peter:onWarpIn(1)
        self.timon:onWarpIn(2)
        self.peter.scale:set(0)
        self.timon.scale:set(0)
        self:onLevelWarp(self.map:getCurrentLevel(), true)
        -- self.peter.inCutscene = true
        -- self.timon.inCutscene = true
        -- local level = self.map:getCurrentLevel()

        -- local preparedCutscene = self.preparedCutscenes[level]
        -- local executedPrepared = false

        -- local cutscene, flagChecked

        -- if preparedCutscene then
        --     cutscene = require("data.cutscenes." .. preparedCutscene)
        --     flagChecked = cutscene.flag and FlagManager:get(cutscene.flag)
        -- end

        -- local callback = function(e)
        --     self.doorTransition = false
        --     e:setPermanentSafePosition()

        --     if preparedCutscene and not flagChecked then
        --         if not executedPrepared then
        --             executedPrepared = true
        --             self.preparedCutscenes[level] = nil
        --             self:startCutscene(preparedCutscene)
        --         end
        --     else
        --         e.inCutscene = false
        --     end
        -- end
        -- checkpointEntity:warpPlayersOut(callback)
    else
        local flip = checkpointEntity.direction == "Left"
        self.peter.flip.x = flip
        self.timon.flip.x = flip
        self.peter:centerX(checkpointEntity:centerX())
        self.timon:centerX(checkpointEntity:centerX())
        if self.checkpoint.type == GameManager.CheckpointType.Reviver then
            self.peter.y = self.peter.y - 18
            self.timon.y = self.timon.y - 18
            self.players:teleportToCheckpoint(checkpointEntity, true)
        end
    end

    self.cameraFollow:set(self.peter:center())
    self.camera.followPoint:clone(self.cameraFollow)
end

function GameManager:registerDestroyedPickupable(pickupable)
    self.pickupablesToBePermanentlyDestroyed:add(pickupable)
end

function GameManager:onPlayerEnteringDoor(door, doorLeft)
    if not self.doorTransition then
        return
    end

    if self.doorTransitionLeft ~= doorLeft then
        return
    end

    if self.transitionBars:isInProgress() then
        return
    end

    self.players:foreach(function(e)
        e.useGravity = false
        e.accel.y = 0
        e.SM:lock(e.MS.Walk)
    end)

    self:delay(.15, function()
        self.players:cutsceneStopWalking()
        self.players:centerX(doorLeft and door:left() - 40 or door:right() + 40)
        self.players:bottom(door:bottom())
        self.players(function(e) e.velocity.y = 0 end)
    end)

    self.transitionBars:start(self.doorTransitionLeft, self.map)
end

function GameManager:onReachingCheckpoint(entity)
    if self.inBossFight then
        return
    end

    if self.checkpoint and self.checkpoint.mapEntityId == entity.mapEntityId then
        return
    end

    self.pickupablesToBePermanentlyDestroyed:foreach(function(e)
        e.mapLevel:registerDestroyedEntity(e.mapEntityId)
    end)

    local checkpoint_type
    if entity.tag == "Door" then
        if not self.doorTransition then return end
        checkpoint_type = GameManager.CheckpointType.Door
    elseif entity.tag == "Reviver" then
        checkpoint_type = GameManager.CheckpointType.Reviver
        self.lastReviver = entity
    elseif entity.tag == "Telegate" then
        checkpoint_type = GameManager.CheckpointType.Warp
    else
        checkpoint_type = GameManager.CheckpointType.Normal
    end

    self.checkpoint = {
        level = entity.mapLevel.id,
        type = checkpoint_type,
        mapEntityId = entity.mapEntityId
    }

    self:saveGame()

    if not entity.boss then
        self:tween(self.saveIcon, .3, { alpha = 1 })
            :after(.6, { alpha = 0 }):delay(3)
    end
end

function GameManager:onInitializingBoss()
    self.inBossFight = true
    local checkpoint = self:findEntityWithTag("Checkpoint")
    if checkpoint then
        self.bossCheckpoint = checkpoint
        self.checkpoint = {
            level = self.map:getCurrentLevel().id,
            type = GameManager.CheckpointType.Normal,
            mapEntityId = checkpoint.mapEntityId
        }
    end
end

function GameManager:onPlayerChangingHealth(player)
    Save:set("game.health." .. player.tag:lower() .. ".current", player.health)
    self.ui:updateHealth(player.tag:lower(), player.health)
end

function GameManager:onEuroPickedUp()
    local euros = Save:get("game.euro")
    euros = euros + 1
    Save:set("game.euro", euros)
    Save:increase("game.stats.euro")
    self.ui:updateEuros(euros)
end

function GameManager:startRoofScene(player)
    -- self.ui:hide()
    -- self:setMap("roof")
    -- self.map:toLevel(0, false)
    Save:set("game.stats.main_event", player:lower())
    self:fadeIn(1)
    self:addOverlay(SadRoof(player, function()
        self.roofEvent = false
        self.map:toLevel("Sicko", true, false)
    end))
end

function GameManager:startNewGame()
    local savedata = require "data.savedata"
    Save:set("game", savedata.game)
    Save:set("game.started", true)

    FlagManager:reset()

    local start = self:findEntityWithTag("StartScene")
    self.inMenu = false
    start:startNewGame()

    self.ui:init()
end

function GameManager:saveGame()
    if #self.pickupablesToBePermanentlyDestroyed > 0 then
        local data = Save:get("game.pickupables") or {}
        for __, pickupable in ipairs(self.pickupablesToBePermanentlyDestroyed) do
            if not data[pickupable.mapLevel.id] then
                data[pickupable.mapLevel.id] = {}
            end

            table.insert(data[pickupable.mapLevel.id], pickupable.mapEntityId)
        end

        Save:set("game.pickupables", data)
        self.pickupablesToBePermanentlyDestroyed:clear()
    end

    if self.peter then
        Save:set("game.health.peter.current", self.peter.health)
        Save:set("game.health.timon.current", self.timon.health)
    end
    Save:set("game.checkpoint", self.checkpoint)
    Save:save()
end

function GameManager:loadGame()
    local checkpoint = Save:get("game.checkpoint")
    if not checkpoint then
        self:startNewGame()
        return
    end

    self:fadeOut(1, function()
        self.darkness:setDarkness(0)
        self.camera:zoomTo(1)
        self.inMenu = false
        self.menu:destroy()
        self.checkpoint = Save:get("game.checkpoint")
        self:applyDestroyedPickupables()
        self.ui:init()
        self.ui:show()
        -- self.map:toLevel(self.checkpoint.level, true, false)
        self:restartLevel(self.checkpoint.level)
    end)
end

function GameManager:applyDestroyedPickupables()
    local data = Save:get("game.pickupables")
    if data then
        for id, v in pairs(self.map.levels) do
            if data[id] then
                for ___, mapEntityId in ipairs(data[v.id]) do
                    v:registerDestroyedEntity(mapEntityId)
                end
            end
        end
    end
end

function GameManager:createPauseMenu()
    if self.goingToMainMenu then return end
    self.wasMusicPlayingBeforePausing = self.music:isPlaying()
    self.inPauseMenu = true
    self.music:pause()
    self.pauseMenu = self:addOverlay(Menu(true, self))

    if self.ufoGame then
        self.ufoGame.music:pause()
    end

    if self.room and self.room.music then
        self.room.music:pause()
    end
end

function GameManager:quitPauseMenu()
    self.inPauseMenu = false
    self.pauseMenu = nil

    if self.ufoGame then
        self.ufoGame.music:resume()
    end

    if self.cutscene and self.cutscenePausesMusic and not self.wasMusicPlayingBeforePausing then
        return
    end

    if self.wasMusicPlayingBeforePausing then
        self.music:resume()
    end

    if self.room and self.room.music then
        self.room.music:resume()
    end
end

function GameManager:toMainMenu(skipFade)
    self.goingToMainMenu = true

    Save:restore()
    FlagManager:reset()

    if self.fightingGame then
        self.ambience:stop(.5)
        self.fightingGame.music:stop(.5)
    end

    if skipFade then
        self.scene:setScene(GameManager())
    else
        self:fadeOut(1, function()
            self.scene:setScene(GameManager())
        end)
    end
end

function GameManager:toIntro()
    self.goingToMainMenu = true

    self:fadeOut(1, function()
        self.scene:toIntro()
    end)
end

function GameManager:updateShader(dt)
    if self.shaderUpdater then
        self:shaderUpdater(dt)
    end
end

function GameManager:startWaterTransition(water, player, out, direction)
    if self.waterTransition then
        return
    end

    self.waterTransition = out and "out" or "in"

    self.map:follow(self.cameraFollow)

    self.players:foreach(function(e)
        e.inCutscene = true
        if out then
            e:swimOutOfWater()
        end
    end)

    -- self.transitionBars:start(self.doorTransitionLeft, self.map)
    self:fadeOut(out and .5 or 1, function()
        self.map.useTransition = false

        self.peter:stopMoving()
        self.timon:stopMoving()
        self.peter.movementDirection = nil
        self.peter.lastInputDirection = nil

        self.timon.movementDirection = nil
        self.timon.lastInputDirection = nil

        if out then
            local x, y = water:center()
            if direction == "Left" then
                self.peter:center(x - 200, y - 400)
                self.timon:center(x - 200, y - 400)
            else
                self.peter:center(x + 200, y - 400)
                self.timon:center(x + 200, y - 400)
            end

            local cb = self.map:getActivateWaitCallback()
            if cb then cb() end
        else
            local x, y = water:center()
            self.peter:center(x, y)
            self.timon:center(x, y)

            water.solid = 0

            local cb = self.map:getActivateWaitCallback()
            if cb then cb() end
        end
    end)
end

function GameManager:goIntoWater()
    if self.inWater then return end
    self.players:goIntoWater()
    self.inWater = true

    self.waterRect = self:addOverlay(Rect(0, 0, WIDTH, HEIGHT))
    self.waterRect:setColor(61, 112, 189, .2)

    self.effectsCamera = moonshine(WIDTH, HEIGHT, moonshine.effects.waves)
    self.effectsCamera.waves.curves = 10
    self.effectsCamera.waves.amount = 0.2
    self.waterWavesTimer = 0
end

function GameManager:goOutWater()
    if not self.inWater then return end
    self.players:goOutWater()
    self.inWater = false

    self.waterRect:destroy()
    self.waterRect = nil

    self.effectsCamera = nil
end

function GameManager:setDeathScreen(deathscreen)
    if self.deathScreen then
        self.deathScreen:destroy()
    end

    if not deathscreen then
        self.deathScreen = self:addOverlay(self.deathScreenDefault())
        return
    end

    self.deathScreen = self:addOverlay(deathscreen)
    self.deathScreen.visible = false
end

function GameManager:getCheckpointX()
    local entity = self:findEntity(function(e) return e.mapEntityId == self.checkpoint.mapEntityId end)
    if not entity then return nil end
    return entity:centerX()
end

function GameManager:teleportPlayersBackToCheckpoint()
    local entity = self:findEntity(function(e) return e.mapEntityId == self.checkpoint.mapEntityId end)
    self.players:teleportToCheckpoint(entity)
end

function GameManager:isTelegateActive(telegate)
    return Save:get("game.telegates." .. telegate.mapEntityId)
end

function GameManager:saveTelegateActive(telegate)
    Save:set("game.telegates." .. telegate.mapEntityId, true)
end

function GameManager:rumble(id, strength, duration)
    if duration then
        self:specificRumble(id, strength, duration)
    else
        duration = strength
        strength = id
    end

    local peter = Save:get("settings.controls.peter")
    if peter.rumble then
        if peter.player1 then
            Input:rumble(1, strength, duration)
        else
            Input:rumble(2, strength, duration)
        end
    end

    local timon = Save:get("settings.controls.timon")
    if timon.rumble then
        if timon.player1 then
            Input:rumble(1, strength, duration)
        else
            Input:rumble(2, strength, duration)
        end
    end
end

function GameManager:specificRumble(id, strength, duration)
    local peter = Save:get("settings.controls.peter")
    local peter_id = peter.player1 and 1 or 2
    if peter_id == id then
        if peter.rumble then
            Input:rumble(id, strength, duration)
        end
        return
    end

    local timon = Save:get("settings.controls.timon")
    local timon_id = timon.player1 and 1 or 2
    if timon_id == id then
        if timon.rumble then
            Input:rumble(id, strength, duration)
        end
    end
end

function GameManager:startWakuMinigame()
    self:fadeOut(1, function()
        self.inWakuMinigame = true
        self.map:toLevel("Computer3", true, false)
        self.camera:zoomTo(1)
        self.inMenu = false
        self:fadeIn(1, function()
        end)
    end)
end

function GameManager:showNotification(text)
    self.players(function(e) e.inControl = false end)
    self:tween(self.darkenGameRect, .25, { alpha = .5 })
    self:tween(self.notificationText, .25, { alpha = 1 })
    self.notificationText:write(text)
    self.showingNotification = true
    self.hideDocumentDelay()
end

function GameManager:hideNotification()
    self.players(function(e) e.inControl = true end)
    self:tween(self.darkenGameRect, .25, { alpha = 0 })
    self:tween(self.notificationText, .25, { alpha = 0 })
    self.showingNotification = false
end

function GameManager:goToEnding()
    Save:save("beatGame", true)
    Save:save("game.beatGame", true)
    self:setScene(Ending())
    -- self:setScene(Credits())
    -- self:fadeIn()
    -- local video = self:addOverlay(Video(0, 0, "ending 3"))
    -- video.scale:set(0.5)
    -- video:play()
end

function GameManager:goToSpeech()
    -- self.music:getSong():stop()
    self:setScene(Speech())
end

function GameManager:goToCredits(skippable)
    if not skippable then
        self:clearCache()
        self:setCheckpointCompletedGame()
        self:setScene(Credits(skippable))
    else
        self:fadeOut(.5, function()
            self:setScene(Credits(skippable))
        end)
    end
end

function GameManager:setCheckpointCompletedGame()
    Save:set("game.checkpoint", {
        level = "Telegate_roof",
        type = GameManager.CheckpointType.Door,
        mapEntityId = "c6a73d62-6280-11ee-93bb-f9838687f2bb"
    })
    Save:save()
end

function GameManager:clearCache()
    local Asset = require "base.asset"
    Asset.clearCache()
end

return GameManager
