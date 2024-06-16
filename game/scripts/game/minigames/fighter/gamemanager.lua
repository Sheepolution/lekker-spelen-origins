local Peter = require("peter", ...)
local Timon = require("timon", ...)
local Rect = require "base.rect"
local RoofThunder = require "decoration.roof_thunder"
local UI = require("ui", ...)
local Sprite = require "base.sprite"
local Text = require "base.text"
local WaterBackground = require "decoration/water_background"
local Music = require "base.music"
local SFX = require "base.sfx"
local Scene = require "base.scene"

local GameManager = Scene:extend("GameManager")

GameManager.SFX = {
    winRound = SFX("sfx/minigames/fighter/win_round"),
    winGame = SFX("sfx/minigames/fighter/win_game"),
}

function GameManager:new(training)
    GameManager.super.new(self)

    self:setMap("fighter")
    self.map:toLevel(0)
    self.tileWidth = 246

    self.z = -50

    self.music = Music("music/minigames/fighter", "epic", "warmup")
    if training then
        self.music:play("warmup", 1, true, .89)
    end

    self:spawnPlayers()

    self.camera:setWorld(self.tileWidth, 245, self.tileWidth * 5, HEIGHT)
    self.camera.lerp = 2

    self.cameraFollow = Rect()
    self:updateCamera(0)
    self.camera:follow(self.cameraFollow, true)

    self.wins = {
        peter = 0,
        timon = 0
    }

    self.background = self:add(WaterBackground())

    self.ui = self:addOverlay(UI())
    self.ui.z = 1

    self.winPeterLeft = self:addOverlay(Sprite(0, 0, "minigames/fighter/peter_wins_left"))
    self.winPeterRound = self:addOverlay(Sprite(0, 0, "minigames/fighter/peter_round_right"))
    self.winPeterRight = self:addOverlay(Sprite(0, 0, "minigames/fighter/peter_wins_right"))

    self.winTimonRight = self:addOverlay(Sprite(0, 0, "minigames/fighter/timon_wins_right"))
    self.winTimonRound = self:addOverlay(Sprite(0, 0, "minigames/fighter/timon_round_left"))
    self.winTimonLeft = self:addOverlay(Sprite(0, 0, "minigames/fighter/timon_wins_left"))

    self.winScreenGraphics = list({
        self.winPeterLeft,
        self.winPeterRound,
        self.winPeterRight,
        self.winTimonLeft,
        self.winTimonRound,
        self.winTimonRight
    })

    self.winScreenGraphics:foreach(function(graphic)
        graphic.visible = false
    end)

    self.roundText = self:addOverlay(Text(0, 0, "Inkompotje"))
    self.roundText:setFont("mk1", 48, nil, "mono")
    self.roundText:center(WIDTH / 2, HEIGHT / 2)
    self.roundText:setAlign("center", 1000)
    self.roundText.visible = false
    self.roundText.shadow:set(4, 4)

    self.fightText = self:addOverlay(Text(0, 0, "FIGHT!"))
    self.fightText:setFont("mk1", 48, nil, "mono")
    self.fightText:setColor(255, 255, 0)
    self.fightText:center(WIDTH / 2, HEIGHT / 2)
    self.fightText:setAlign("center", 1000)
    self.fightText.visible = false
    self.fightText.shadow:set(4, 4)

    self.round = training and -1 or 0

    self:fadeIn(1, self.F:startRound())
end

function GameManager:done()
    self:prepareNextRound()
end

function GameManager:update(dt)
    if self.slowmo then dt = dt * .3334 end
    GameManager.super.update(self, dt)
end

function GameManager:updateCamera(dt)
    -- Center between Peter and Timon
    local px, py = self.peter:center()
    local tx, ty = self.timon:center()
    local x = (px + tx) / 2
    local y = (py + ty) / 2
    self.cameraFollow:set(_.floor(x), _.floor(y))
    GameManager.super.updateCamera(self, dt)
end

function GameManager:onLosingHealth(player, decrease, current)
    self.ui:decreaseHealth(player.tag:lower(), decrease)
end

function GameManager:setSlowmo(set)
    self.slowmo = set
end

function GameManager:onWin(player)
    local tag = player.tag:lower()

    if self.round > 0 then
        self.wins[tag] = self.wins[tag] + 1
        self.ui:addWin(tag)
        self:delay(2, function()
            self:showWinScreen(tag)
        end)

        return self.wins[tag] >= 2
    else
        self:delay(2, function()
            self.roundText:write("Inkompotje.\nTelt niet.")
            self.roundText.visible = true
            self:delay(5, function()
                self:fadeOut(1, function()
                    self.roundText.visible = false
                    self:prepareNextRound()
                    self:delay(3.5, self.wrap:fadeIn(1.5, self.F:startRound(), false))
                end, false)
            end)
        end)
    end

    return false
end

function GameManager:showWinScreen(tag)
    local left, right
    if tag == "peter" then
        self.winPeterLeft.visible = true
        self.winPeterLeft.x = -self.winPeterLeft.width
        left = self.winPeterLeft

        if self.wins[tag] == 1 then
            self.winPeterRound.visible = true
            self.winPeterRound.x = WIDTH
            right = self.winPeterRound
        else
            self.winPeterRight.visible = true
            self.winPeterRight.x = WIDTH
            right = self.winPeterRight
        end
    else
        self.winTimonRight.visible = true
        self.winTimonRight.x = WIDTH
        right = self.winTimonRight

        if self.wins[tag] == 1 then
            self.winTimonRound.visible = true
            self.winTimonRound.x = -self.winTimonRound.width
            left = self.winTimonRound
        else
            self.winTimonLeft.visible = true
            self.winTimonLeft.x = -self.winTimonLeft.width
            left = self.winTimonLeft
        end
    end

    self:tween(left, .5, { x = 0 }):ease("quintin")
    self:tween(right, .5, { x = WIDTH / 2 }):ease("quintin")


    if self.wins[tag] == 2 then
        self.roofThunder:setNoLightningSFX()
        self.SFX.winGame:play()
    else
        self.SFX.winRound:play()
    end

    self:delay(5, self.wrap:fadeOut(1, function()
        if self.wins[tag] == 2 then
            self.music:stop(.5)
            self.scene:onFightingGameWin(tag)
            self:delay(1, self.F:destroy())
        else
            self:prepareNextRound()
            self:delay(1, self.wrap:fadeIn(1, self:startRound()))
        end
    end, false))
end

function GameManager:prepareNextRound()
    self.peter:destroy()
    self.timon:destroy()

    self:spawnPlayers()

    self.ui:resetHealth()
    self.winScreenGraphics:foreach(function(graphic)
        graphic.visible = false
    end)

    self.round = self.round + 1

    if self.round == 1 then
        self.map:destroy()
        self:setMap("fighter_wet")
        self.map:toLevel(0)
        self.background:destroy()
        self.roofThunder = self:addUnderlay(RoofThunder())
        self.music:play("epic", 2, true, 7.74)
        self.ui:addStars()
        self.scene.ambience:play("rain_wind", 3)
    end
end

function GameManager:startRound()
    if self.round > 0 then
        self.roundText:write("Round " .. self.round)
        self.roundText.visible = true
    end

    self:delay(3, function()
        self.roundText.visible = false
        self.fightText.visible = true

        self.peter.inControl = true
        self.timon.inControl = true

        self:delay(1, function()
            self.fightText.visible = false
        end)
    end)
end

function GameManager:spawnPlayers()
    self.peter = self:add(Peter())
    self.timon = self:add(Timon())

    local cx = self.map.currentLevel.width / 2 - 50
    self.peter:center(cx - 200, 575)
    self.timon:center(cx + 200, 575)

    self.peter:setOpponent(self.timon)
    self.timon:setOpponent(self.peter)
end

return GameManager
