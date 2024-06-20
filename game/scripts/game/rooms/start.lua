local websocket = require "libs.websocket"
local Rect = require "base.rect"
local Lightbulb = require "decoration.lightbulb"
local Logo = require "menu.logo"
local Sprite = require "base.sprite"
local Scene = require "base.scene"
local Text = require "base.text"
local Entity = require "base.entity"

local Start = Scene:extend("StartScene")

function Start:new(x, y, mapLevel)
    Start.super.new(self)
    self:setBackgroundAlpha(0)
    self.mapLevel = mapLevel
    self.x = x
    self.y = y
end

function Start:done()
    self.desk = self.mapLevel:add(Entity(self.x + -57, self.y + 335, "decoration/desk_central", true), true)
    self.desk:clearHitboxes()
    self.desk:addHitbox(0, 5, self.desk.width, 20)
    self.desk.alpha = 0

    self.computer = self.mapLevel:add(Sprite(self.x + 16, self.y + 347, "decoration/pc_central", true), true)
    self.computer.tag = "Computer"
    self.computer.anim:set("off")
    self.computer.alpha = 0

    self.computer.anim:getAnimation("turn_on")
        :onStart(function()
            self.computerLight = self.scene:addLightSource(self.computer, 100)
        end)
        :onComplete(function()
            self.computerLight:destroy()
        end)

    self.lightbulb = self.mapLevel:add(Lightbulb(self.x + 39, self.y + 108, "decoration/desk_central", true), true)

    if self.scene.inMenu then
        self:setupForMenu()
    else
        self:setupForRevisit()
    end

    self.background:add("coat_rack", 579, 360)
    self.background:add("sets/bureau0", -657, 365)
    self.background:add("spinnenweb_links_xl", -880, 120)
    self.background:add("bord_nooduitgang_rechts", 822, 296)
    self.background:add("cam_rechts_voor", -1265, 278)
    self.background:add("spinnenweb_rechts_m", 877, 120)
    self.background:add("flora/set/2", -833, 445)
    self.background:add("flora/set/3", 685, 445)
    self.background:add("flora/set/1", -1000, 436, true)
    self.background:add("flora/set/10", -1078, 315)
    self.background:add("flora/set/12", -1190, 430)
    self.background:add("flora/set/5", 791, 416)
end

function Start:update(dt)
    Start.super.update(self, dt)
    if self.client then
        self.client:update(dt)
    end
end

function Start:setupForMenu()
    self.scene.camera:moveToPoint(self.computer:centerX() - 7, HEIGHT / 2 + 100)
    self.scene.camera:zoomTo(2)
    self.scene.darkness:setDarkness(1)
    self.logo = self.scene:addOverlay(Logo())
    self.logo.removeOnLevelChange = true

    self.lightbulb:startUp()
    self:delay(2, function()
        self.scene:findEntitiesWithTag("Tube"):startUp()
    end)

    self:delay(2.5, function()
        self.logo:startUp()
        -- self.logo:destroy()
        self:delay(2.5, function()
            self.versionText.visible = true
        end)
    end)

    self.darkCoverRect = self.mapLevel:add(Rect(self.x - 50, self.y + 450, 200, 400))
    self.darkCoverRect:setColor(14, 18, 26)

    self.scene.music:play("menu", 1, true)

    self.scene.cutscenePausesMusic = false

    self.versionText = self.scene:addOverlay(Text(10, 520, "v" .. GAME_VERSION))
    self.versionText.z = ZMAP.TOP
    self.versionText.removeOnLevelChange = true
    self.versionText:setColor(255, 255, 255)
    self.versionText.visible = false

    if LEKKER_SPELEN then
        self:connectWithChat()
    end
end

function Start:hideLogo()
    return self.logo:hide()
end

function Start:startNewGame()
    self.darkCoverRect:destroy()
    self.versionText:destroy()
    self:delay(1, function()
        self.desk.alpha = 1
        self.computer.alpha = 1
        self.scene.darkness:toDarkness(.6, 2)
        self:delay(2, function()
            self.scene.ui.visible = false
            self.scene:startCutscene("intro", nil, true)
            self:delay(2, function()
                self.scene.ui.visible = true
            end)
        end)
    end)
end

function Start:setupForRevisit()
    self.scene.darkness:setDarkness(.6)
    self.lightbulb:beBroken()
    self.computer.alpha = 1
    self.desk.alpha = 1
    self.desk:setColor(150, 150, 150)
    self.scene.music:play("mystery", 1)
end

function Start:connectWithChat()
    ---@diagnostic disable-next-line: missing-parameter
    self.client = websocket.new(SERVER_IP, 8082)

    ---@diagnostic disable-next-line: duplicate-set-field
    self.client.onopen = function()
        self.versionText.x = WIDTH - 40
        self.client:close()
        self.client = nil
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    self.client.onerror = function()
        self.client:close()
        self.client = nil
    end
end

return Start
