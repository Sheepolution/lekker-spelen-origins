local libs = require "libs"
local FlagManager = require "flagmanager"
local SFX = require "base.sfx"
local Music = require "base.music"
local push = require("libs").push
local Save = require "base.save"
local Text = require "base.text"
local Input = require "base.input"
local Sprite = require "base.sprite"
local Rect = require "base.rect"
local BlueprintDocument = require "documents.blueprint"
local LogDocument = require "documents.log"
local BlueprintMenu = require "menu.blueprint"
local LogMenu = require "menu.log"
local Star = require "menu.star"
local Scene = require "base.scene"

local Menu = Scene:extend("Menu")

Menu.itemFadeSpeed = .2
Menu.itemListStartPosition = HEIGHT / 2 - 90
Menu.itemMargin = 45

Menu.keys = {
    left = { "left", "a", "c1_left_left", "c1_dpleft", "c2_left_left", "c2_dpleft" },
    right = { "right", "d", "c1_left_right", "c1_dpright", "c2_left_right", "c2_dpright" },
    up = { "up", "w", "c1_left_up", "c1_dpup", "c2_left_up", "c2_dpup" },
    down = { "down", "s", "c1_left_down", "c1_dpdown", "c2_left_down", "c2_dpdown" },
    confirm = { "space", "return", "c1_a", "c2_a" },
    start = { "c1_start", "c2_start", "escape" },
    exit = { "escape", "c1_start", "c2_start" },
    back = { "backspace", "c1_back", "c1_b", "c2_back", "c2_b" },
}

function Menu:new(pause, scene)
    Menu.super.new(self)
    self:setBackgroundAlpha(0)

    self.pauseMenu = pause
    self.scene = scene

    if pause then
        self:tween(.3, { backgroundAlpha = .8 })
    end

    self.indicatorLeft = self:add(Sprite(0, 0, "menu/horizontal_indicator"))
    self.indicatorRight = self:add(Sprite(0, 0, "menu/horizontal_indicator"))
    self.indicatorLeft.flip.x = true
    self.indicatorLeft.visible = false
    self.indicatorRight.visible = false

    self.context = self:addTextItem(Menu.itemListStartPosition - 90, "Dit is een test", 32)
    self.context.alpha = 0

    self.itemPressStart = self:addTextItems({
        {
            content = "Druk op START",
            method = self.onPressStart,
        }
    })

    self.itemPressStart[1].y = HEIGHT - 100

    self.mainItems = self:addTextItems({
        {
            content = "Verder spelen",
            method = self.onPressContinue,
            condition = function()
                return Save:get("game.started")
            end
        },
        {
            content = "Terug naar centraal punt",
            method = self.onPressBackToCentralHub,
            condition = function()
                if not self.pauseMenu or self.scene.warpningToLevel then
                    return false
                end

                local level_name = self.scene.map:getCurrentLevel().id

                if level_name:find("_end") then
                    return false
                end

                if level_name:find("Horsey_") then
                    return FlagManager:get(Enums.Flag.hasAccessPass2)
                end

                if level_name:find("Water_") then
                    return FlagManager:get(Enums.Flag.hasAccessPass3)
                end

                if level_name:find("Horror_") or level_name == "Hellhound" or level_name == "Centaur_boss" then
                    return FlagManager:get(Enums.Flag.hasAccessPass4)
                end

                if level_name:find("Konkie_") then
                    return FlagManager:get(Enums.Flag.hasAccessPass5)
                end

                return false
            end
        },
        {
            content = "Lekker spelen",
            method = self.onPressPlay,
            condition = function()
                return not Save:get("game.started") and not self.pauseMenu
            end
        },
        {
            content = "Lekker spelen",
            method = self.onPressPlayQuestion,
            condition = function()
                return Save:get("game.started") and not self.pauseMenu
            end
        },
        {
            content = "[GEHEIMPIE]",
            locked = true,
            condition = function()
                return not Save:get("minigames.waku") and not self.pauseMenu
            end
        },
        {
            content = "Miniogames",
            method = self.onPressMinigames,
            condition = function()
                return Save:get("minigames.waku") and not self.pauseMenu
            end
        },
        {
            content = "[GEHEIMPIE]",
            locked = true,
            condition = function()
                return #Save:get("documents.blueprints") == 0 and #Save:get("documents.logs") == 0
            end
        },
        {
            content = "Documenten",
            method = self.onPressDocuments,
            condition = function()
                return #Save:get("documents.blueprints") > 0 or #Save:get("documents.logs") > 0
            end
        },
        {
            content = "[GEHEIMPIE]",
            locked = true,
            condition = function()
                return not Save:get("beatGame") and not self.pauseMenu
            end
        },
        {
            content = "Credits",
            method = self.onPressCredits,
            condition = function()
                return Save:get("beatGame") and not self.pauseMenu
            end
        },
        { content = "Opties", method = self.onPressOptions },
        {
            content = (self.pauseMenu and "Hoofdmenu" or "Afsluiten"),
            method = self.onPressExit,
        },
    })

    self.newGameConfirmItems = self:addTextItems({
        { content = "Ja",  method = self.onPressPlay },
        { content = "Nee", method = self.onPressBack },
    }, nil, "Nieuw spel starten?\nJe behoudt de documents/minigames.")

    self.minigamesItems = self:addTextItems({
        {
            content = "[GEHEIMPIE]",
            locked = true,
            condition = function()
                return not Save:get("minigames.spacer_racer")
            end
        },
        {
            content = "Spacer Racer",
            method = self.onPressSpacerRacer,
            condition = function()
                return Save:get("minigames.spacer_racer")
            end
        },
        {
            content = "WAKU WAKU",
            method = self.onPressWaku,
        },
        {
            content = "[GEHEIMPIE]",
            locked = true,
            condition = function()
                return not Save:get("minigames.fighter")
            end
        },
        {
            content = "PETER vs TIMON",
            method = self.onPressFighter,
            condition = function()
                return Save:get("minigames.fighter")
            end
        },
        { content = "Terug", method = self.onPressBack },
    }, nil, "Miniogames")

    self.fightingGameItems = self:addTextItems({
        {
            content = "Met inkompotje",
            method = self.onPressFighterWithTraining,
        },
        {
            content = "Zonder inkompotje",
            method = self.onPressFighterWithoutTraining,
        },
        { content = "Terug", method = self.onPressBack },
    }, nil, "PETER vs TIMON")

    self.documentItems = self:addTextItems({
        {
            content = "Logboek",
            method = self.onPressLogs,
        },
        {
            content = "[GEHEIMPIE]",
            locked = true,
            condition = function()
                return #Save:get("documents.blueprints") == 0
            end
        },
        {
            content = "Blauwdrukken",
            method = self.onPressBlueprints,
            condition = function()
                return #Save:get("documents.blueprints") > 0
            end
        },
        { content = "Terug", method = self.onPressBack },
    }, nil, "Documenten")

    self.optionItems = self:addTextItems({
        { content = "Besturing", method = self.onPressControls },
        { content = "Scherm",    method = self.onPressScreen },
        { content = "Geluid",    method = self.onPressAudio },
        { content = "Terug",     method = self.onPressBack },
    }, nil, "Opties")

    self.controlsItems = self:addTextItems({
        { content = "Peter", method = self.onPressControlsPeter },
        { content = "Timon", method = self.onPressControlsTimon },
        { content = "Terug", method = self.onPressBack },
    }, nil, "Besturing")

    self.controlsPeterItems = self:addTextItems({
        {
            content = {
                path = "settings.controls.peter.player1",
                content = {
                    [true] = "Speler 1",
                    [false] = "Speler 2",
                }
            },
            method = self.onPressControlsPeterPlayer
        },
        {
            content = {
                path = "settings.controls.peter.rumble",
                content = {
                    [true] = "Peter is een rumble-man",
                    [false] = "Peter is GEEN rumble-man",
                }
            },
            method = self.onPressControlsPeterRumble
        },
        { content = "Terug", method = self.onPressBack },
    }, nil, "Besturing Peter")

    self.controlsTimonItems = self:addTextItems({
        {
            content = {
                path = "settings.controls.timon.player1",
                content = {
                    [true] = "Speler 1",
                    [false] = "Speler 2",
                }
            },
            method = self.onPressControlsTimonPlayer
        },
        {
            content = {
                path = "settings.controls.timon.rumble",
                content = {
                    [true] = "Timon is een rumble-man",
                    [false] = "Timon is GEEN rumble-man",
                }
            },
            method = self.onPressControlsTimonRumble
        },
        { content = "Terug", method = self.onPressBack },
    }, nil, "Besturing Timon")

    self.screenItems = self:addTextItems({
        {
            content = {
                path = "settings.screen.fullscreen",
                content = {
                    [true] = "Ik ben een fullscreen-man",
                    [false] = "Ik ben een windowed-man",
                }
            },
            method = self.onPressFullscreen
        },
        {
            content = {
                path = "settings.screen.pixelperfect",
                content = {
                    [true] = "Ik ben een pixel perfect-man",
                    [false] = "Ik ben een stretching-man",
                }
            },
            method = self.onPressPixelPerfect
        },
        {
            content = {
                path = "settings.screen.sharp",
                content = {
                    [true] = "Ik ben een scherp-man",
                    [false] = "Ik ben een smooth-man",
                }
            },
            method = self.onPressPixel
        },
        {
            content = {
                path = "settings.screen.vsync",
                content = {
                    [true] = "Ik ben een vsync-man",
                    [false] = "Ik ben GEEN vsync-man",
                }
            },
            method = self.onPressVsync
        },
        { content = "Terug", method = self.onPressBack },
    }, nil, "Scherm")

    self.audioItems = self:addTextItems({
        {
            content = {
                path = "settings.audio.master",
                max = 100,
                min = 0,
                content = {
                    convert = "Master\n{1}%",
                },
                horizontal = true,
            },
            method = self.onPressMaster
        },
        {
            content = {
                path = "settings.audio.music",
                max = 100,
                min = 0,
                content = {
                    convert = "Music\n{1}%",
                },
                horizontal = true,
            },
            method = self.onPressMusic
        },
        {
            content = {
                path = "settings.audio.sfx",
                max = 100,
                min = 0,
                content = {
                    convert = "SFX\n{1}%",
                },
                horizontal = true,
            },
            method = self.onPressSFX
        },
        { content = "Terug", method = self.onPressBack },
    }, Menu.itemMargin + 30, "Audio")

    self.selectedItemNumber = 1
    self.menuTree = {}

    if not pause then
        self.active = false
        self.startupDelay = self:delay(6, function()
            self.active = true
            self.startupDelay = nil
            self:showItems(self.itemPressStart, 1)
        end)
    else
        self:delay(.1, function()
            self.active = true
        end)
        self:showItems(self.mainItems, 1)
    end

    self.repeatInputDelay = step.after(.3)
    self.repeatInputInterval = step.every(.05)

    self.darkOverlay = self:add(Rect(0, 0, WIDTH, HEIGHT))
    self.darkOverlay:setColor(0, 0, 0)
    self.darkOverlay.alpha = .9
    self.darkOverlay.visible = false

    self.showingBlueprints = false

    self.checkExitDelay = step.after(.3)
end

function Menu:done()
    if not self.pauseMenu then
        self.selectedItemLight = self.scene:addLightSource(self, 80, 30, true)
        self.selectedItemLight.alpha = 0
    end
end

function Menu:update(dt)
    Menu.super.update(self, dt)

    if self.startupDelay then
        if Input:isPressed(self.keys.start) then
            self.active = true
            self.startupDelay:stop()
            self.startupDelay = nil
            self:showItems(self.itemPressStart, 1)
            return
        end
    end

    if not self.active then return end

    if Input:isPressed(self.keys.start) then
        if self.pauseMenu then
            self:quitMenu()
            return
        else
            self:onPress()
            return
        end
    end

    if Input:isPressed(self.keys.confirm) then
        self:onPress()
    end

    if Input:isPressed(self.keys.back) then
        self:onPressBack()
    end

    if Input:isPressed(self.keys.left) then
        if self.showingBlueprints or self.showingLogs or self.showingUfoLevels then
            self:selectItem(-1)
        else
            self:onPressHorizontal(-1)
        end
    elseif Input:isPressed(self.keys.right) then
        if self.showingBlueprints or self.showingLogs or self.showingUfoLevels then
            self:selectItem(1)
        else
            self:onPressHorizontal(1)
        end
    end

    if Input:isDown(self.keys.left) then
        if self.repeatInputDelay(dt) then
            if self.repeatInputInterval(dt) then
                self:onPressHorizontal(-1)
            end
        end
    elseif Input:isDown(self.keys.right) then
        if self.repeatInputDelay(dt) then
            if self.repeatInputInterval(dt) then
                self:onPressHorizontal(1)
            end
        end
    else
        self.repeatInputDelay()
        self.repeatInputInterval()
    end

    if Input:isPressed(self.keys.up) then
        local n = -1
        if self.showingBlueprints then
            n = -5
        elseif self.showingLogs then
            n = -6
        elseif self.showingUfoLevels then
            n = -3
        end
        self:selectItem(n)
    elseif Input:isPressed(self.keys.down) then
        local n = 1
        if self.showingBlueprints then
            n = 5
        elseif self.showingLogs then
            n = 6
        elseif self.showingUfoLevels then
            n = 3
        end
        self:selectItem(n)
    end

    if self.checkExitDelay(dt) then
        if Input:isPressed(self.keys.exit) then
            if self.pauseMenu then
                self:quitMenu()
            end
        end
    end
end

function Menu:addTextItems(data, margin, context)
    local items = list()

    data = _.filter(data, function(v)
        return not v.condition or v.condition(v)
    end)

    for i, v in ipairs(data) do
        local item = self:addTextItem(Menu.itemListStartPosition + (i - 1) * (margin or Menu.itemMargin), v.content, 32,
            v.method, v.locked)
        item.onPress = v.onPress
        items:add(item)
    end

    if context then
        rawset(items, 'context', context)
    end

    return items
end

function Menu:addTextItem(y, content, size, method, locked)
    local conditional_content
    if type(content) == "table" then
        conditional_content = content
        content = ''
    end

    local text = self:add(Text(0, 0, content, size))
    text:setAlign("center", WIDTH)
    text:center(WIDTH / 2, y)
    text.method = method
    text.alpha = 0
    text.locked = locked

    if conditional_content then
        text.conditionalContent = conditional_content
    end

    return text
end

function Menu:showItems(items, selected, back)
    local context = rawget(items, 'context')
    if not self.pauseMenu then
        self.selectedItemLight.alpha = 1
    end
    self:hideCurrentItems(back)

    selected = selected or 1

    items = items:filter(function(item)
        return not item.condition or item.condition(item)
    end)

    items(function(e, i)
        self:tween(e, Menu.itemFadeSpeed, { alpha = i == selected and 1 or .5 })
        self:refreshConditionalContent(e)
    end)

    self.currentItems = items
    self:selectItem(selected, true)

    if context then
        rawset(self.currentItems, 'context', context)
        self.context:write(context)
        self.context.alpha = 1
    else
        self.context.alpha = 0
    end
end

function Menu:hideCurrentItems(back)
    if not self.currentItems then return end

    if not back then
        self:addToMenuTree()
    end

    self.currentItems(function(e, i)
        self:tween(e, Menu.itemFadeSpeed, { alpha = 0 })
    end)
end

function Menu:addToMenuTree()
    table.insert(self.menuTree, {
        items = self.currentItems,
        selected = self.selectedItemNumber,
    })
end

function Menu:selectItem(n, absolute)
    if self.showingBlueprints then
        self:selectBluePrint(n, absolute)
        return
    end

    if self.showingLogs then
        self:selectLog(n, absolute)
        return
    end

    if self.showingUfoLevels then
        self:selectUfoLevel(n, absolute)
        return
    end

    if #self.currentItems > 1 then
        n = absolute and n or self.selectedItemNumber + n
        n = _.mod(n, #self.currentItems)
        self:deselectCurrenItem()
    elseif not absolute then
        return
    end

    self.selectedItemNumber = n
    self.selectedItem = self.currentItems[self.selectedItemNumber]
    self:tween(self.selectedItem, Menu.itemFadeSpeed, { alpha = 1 })
    if not self.pauseMenu then
        self.selectedItemLight.y = self.selectedItem.y + 13
    end

    self:refreshConditionalContent()
end

function Menu:deselectCurrenItem()
    if not self.selectedItem then return end
    self:tween(self.selectedItem, Menu.itemFadeSpeed, { alpha = .5 })
end

function Menu:refreshConditionalContent(item)
    item = item or self.selectedItem
    if not item.conditionalContent then
        self.indicatorLeft.visible = false
        self.indicatorRight.visible = false
        return
    end
    local value = Save:get(item.conditionalContent.path)
    if value == nil then value = false end

    if item.conditionalContent.content.convert then
        item:write(_.format(item.conditionalContent.content.convert, { value }))
    else
        item:write(item.conditionalContent.content[value])
    end

    if item.conditionalContent.horizontal then
        local width = item:getWidth()
        self.indicatorLeft:center(item:centerX() - width, item:centerY())
        self.indicatorRight:center(item:centerX() + width, item:centerY())

        if type(value) == "number" and item.conditionalContent.max then
            local max = item.conditionalContent.max or 100
            local min = item.conditionalContent.min or 0
            self.indicatorLeft.visible = value > min
            self.indicatorRight.visible = value < max
        else
            self.indicatorLeft.visible = true
            self.indicatorRight.visible = true
        end
    end
end

function Menu:toggleOption()
    local item = self.selectedItem
    local value = Save:get(item.conditionalContent.path)
    Save:set(item.conditionalContent.path, not value)
end

function Menu:hide()
    self.active = false
    self:tween(.5, { alpha = 0 })
    if not self.pauseMenu then
        self:tween(self.selectedItemLight, .5, { alpha = 0 })
            :oncomplete(function() self.selectedItemLight:destroy() end)
    end
end

function Menu:appear()
    self.active = true
    self:tween(.5, { alpha = 1 })

    if self.showingUfoLevels then
        self.ufoTimeText:write(_.clockMMSSmm(Save:get("minigames.sr_times")[self.selectedUfoLevelNumber]))
    end
end

function Menu:createBlueprints()
    self.blueprints = list()
    local blueprints = list(require "data.blueprints")
    local collected = list(Save:get("documents.blueprints"))
    local known = blueprints:map(function(v)
        return collected:contains(v)
    end)

    local width, height, marginX, marginY = 98, 58, 120 - 98, 80 - 58
    local totalWidth = (width + marginX) * 5
    local totalHeight = (height + marginY) * 5
    local spacingX, spacingY = (WIDTH - totalWidth) / 2 + 14, (HEIGHT - totalHeight) / 2

    for i = 0, 4 do
        for j = 0, 4 do
            local x, y = j * (width + marginX) + spacingX, i * (height + marginY) + spacingY
            local blueprint = self.blueprints:add(self:add(BlueprintMenu(x, y,
                blueprints[#self.blueprints + 1],
                known[#self.blueprints + 1])))

            blueprint.visible = false
        end
    end
end

function Menu:showBlueprints()
    if not self.blueprints then
        self:createBlueprints()
    end

    self.showingBlueprints = true
    self.blueprints(function(e)
        e.visible = true
        e.alpha = 0
        self:tween(e, .3, { alpha = 1 })
    end)

    self.currentItems(function(e)
        e.visible = false
    end)

    self:selectBluePrint(1, true)
    self.context.visible = false
end

function Menu:hideBlueprints()
    self.showingBlueprints = false

    self.blueprints(function(e)
        self:tween(e, .3, { alpha = 0 })
            :oncomplete(function() e.visible = false end)
    end)

    self.currentItems(function(e)
        e.visible = true
    end)

    self:deselectBlueprint()
    self.context.visible = true
end

function Menu:selectBluePrint(n, absolute)
    if self.showingSpecificBlueprint then return end
    if not absolute then
        if n == 1 then
            if (self.selectedBlueprintNumber + n) % 5 == 1 then
                n = -4
            end
        elseif n == -1 then
            if (self.selectedBlueprintNumber + n) % 5 == 0 then
                n = 4
            end
        end
        n = _.mod(self.selectedBlueprintNumber + n, #self.blueprints)
    end
    self:deselectBlueprint()
    self.selectedBlueprintNumber = n
    self.selectedBlueprint = self.blueprints[self.selectedBlueprintNumber]
    self.selectedBlueprint:select()
end

function Menu:deselectBlueprint()
    if not self.selectedBlueprint then return end
    self.selectedBlueprint:deselect()
end

function Menu:createLogs()
    self.logs = list()
    local logs = list(require "data.log_names")
    local collected = list(Save:get("documents.logs"))
    local known = logs:map(function(v)
        return collected:contains(v)
    end)

    local width, height, marginX, marginY = 98, 58, 120 - 98, 80 - 58
    local totalWidth = (width + marginX) * 6
    local totalHeight = (height + marginY) * 3
    local spacingX, spacingY = (WIDTH - totalWidth) / 2 + 14, (HEIGHT - totalHeight) / 2

    for i = 0, 2 do
        for j = 0, 5 do
            local x, y = j * (width + marginX) + spacingX, i * (height + marginY) + spacingY
            local log = self.logs:add(self:add(LogMenu(x, y,
                logs[#self.logs + 1],
                known[#self.logs + 1])))

            log.visible = false
        end
    end

    self.logText = self:add(Text(0, 0, "", 32))
    self.logText:setAlign("center", WIDTH)
    self.logText:center(WIDTH / 2, 100)
end

function Menu:showLogs()
    if not self.logs then
        self:createLogs()
    end

    self.showingLogs = true
    self.logs(function(e)
        e.visible = true
        e.alpha = 0
        self:tween(e, .3, { alpha = 1 })
    end)

    self.currentItems(function(e)
        e.visible = false
    end)

    self:selectLog(1, true)
    self.logText.visible = true
    self.context.visible = false
end

function Menu:hideLogs()
    self.showingLogs = false

    self.logs(function(e)
        self:tween(e, .3, { alpha = 0 })
            :oncomplete(function() e.visible = false end)
    end)

    self.currentItems(function(e)
        e.visible = true
    end)

    self:deselectLog()
    self.logText.visible = false
    self.context.visible = true
end

function Menu:selectLog(n, absolute)
    if self.showingSpecificLog then return end
    if not absolute then
        if n == 1 then
            if (self.selectedLogNumber + n) % 6 == 1 then
                n = -5
            end
        elseif n == -1 then
            if (self.selectedLogNumber + n) % 6 == 0 then
                n = 5
            end
        end
        n = _.mod(self.selectedLogNumber + n, #self.logs)
    end

    self:deselectLog()
    self.selectedLogNumber = n
    self.selectedLog = self.logs[self.selectedLogNumber]
    self.selectedLog:select()

    if self.selectedLog.known then
        self.logText:write(self.selectedLog:getName())
    else
        self.logText:write("")
    end
end

function Menu:deselectLog()
    if not self.selectedLog then return end
    self.selectedLog:deselect()
end

function Menu:createUfoLevels()
    self.ufoLevels = list()

    local width, height, marginX, marginY = 98, 58, 120 - 98, 80 - 58
    local totalWidth = (width + marginX) * 3
    local totalHeight = (height + marginY) * 3
    local spacingX, spacingY = (WIDTH - totalWidth) / 2 + 14, (HEIGHT - totalHeight) / 2

    for i = 0, 2 do
        for j = 0, 2 do
            local x, y = j * (width + marginX) + spacingX, i * (height + marginY) + spacingY
            local ufo_level = self.ufoLevels:add(self:add(Star(x, y, (#self.ufoLevels + 1))))
            ufo_level.visible = false
        end
    end

    self.ufoTimeText = self:add(Text(0, 0, "", 32))
    self.ufoTimeText:setAlign("center", WIDTH)
    self.ufoTimeText:center(WIDTH / 2, 100)
end

function Menu:showUfoLevels()
    if not self.ufoLevels then
        self:createUfoLevels()
    end

    self.showingUfoLevels = true
    self.ufoLevels(function(e)
        e.visible = true
        e.alpha = 0
        self:tween(e, .3, { alpha = 1 })
    end)

    self.currentItems(function(e)
        e.visible = false
    end)

    self:selectUfoLevel(1, true)
    self.ufoTimeText.visible = true
    self.context.visible = false
end

function Menu:hideUfoLevels()
    self.showingUfoLevels = false

    self.ufoLevels(function(e)
        self:tween(e, .3, { alpha = 0 })
            :oncomplete(function() e.visible = false end)
    end)

    self.currentItems(function(e)
        e.visible = true
    end)

    self:deselectUfoLevel()
    self.ufoTimeText.visible = false
    self.context.visible = true
end

function Menu:selectUfoLevel(n, absolute)
    if not absolute then
        if n == 1 then
            if (self.selectedUfoLevelNumber + n) % 3 == 1 then
                n = -2
            end
        elseif n == -1 then
            if (self.selectedUfoLevelNumber + n) % 3 == 0 then
                n = 2
            end
        end
        n = _.mod(self.selectedUfoLevelNumber + n, #self.ufoLevels)
    end

    self:deselectUfoLevel()
    self.selectedUfoLevelNumber = n
    self.selectedUfoLevel = self.ufoLevels[self.selectedUfoLevelNumber]
    self.selectedUfoLevel:select()

    self.ufoTimeText:write(_.clockMMSSmm(Save:get("minigames.sr_times")[self.selectedUfoLevelNumber]))
end

function Menu:deselectUfoLevel()
    if not self.selectedUfoLevel then return end
    self.selectedUfoLevel:deselect()
end

-------------------------
-- MENU ITEM FUNCTIONS --
-------------------------
function Menu:onPress()
    if self.showingBlueprints then
        self:onPressSpecificBlueprint()
        return
    end

    if self.showingLogs then
        self:onPressSpecificLog()
        return
    end

    if self.showingUfoLevels then
        self:onPressSpecificSpacerRacerLevel()
        return
    end

    if not self.selectedItem then
        return
    end

    if self.selectedItem.locked then
        self:onPressLockedItem()
        return
    end

    local selected = self.selectedItem
    self.selectedItem.method(self)
    if self.selectedItem == selected then
        if self.selectedItem.conditionalContent then
            self:refreshConditionalContent()
        end
    end
end

function Menu:onPressStartButton()
    local selected = self.selectedItem
    self.selectedItem.method(self)
    if self.selectedItem == selected then
        if self.selectedItem.conditionalContent then
            self:refreshConditionalContent()
        end
    end
end

function Menu:onPressHorizontal(value)
    if not self.selectedItem then
        return
    end

    if not self.selectedItem.conditionalContent then
        return
    end

    if self.selectedItem.conditionalContent.horizontal then
        self.selectedItem.method(self, value)
        self:refreshConditionalContent()
    end
end

function Menu:onPressBack()
    if self.showingSpecificBlueprint then
        self:onPressSpecificBlueprint()
        return
    end

    if self.showingSpecificLog then
        self:onPressSpecificLog()
        return
    end

    if self.showingBlueprints then
        self:hideBlueprints()
        return
    end

    if self.showingLogs then
        self:hideLogs()
        return
    end

    if self.showingUfoLevels then
        self:hideUfoLevels()
        return
    end

    local menu = table.remove(self.menuTree)
    if menu then
        Save:save("settings")
        self:showItems(menu.items, menu.selected, true)
    elseif not self.pauseMenu then
        self:hide()
        self.scene:toIntro()
    else
        self:quitMenu()
    end
end

function Menu:onPressLockedItem()
    self.selectedItem:shake(2, .3)
end

function Menu:quitMenu()
    self.quitting = true
    self:hideCurrentItems()
    self:tween(self.context, Menu.itemFadeSpeed, { alpha = 0 })

    if self.showingBlueprints then
        self.blueprints(function(e)
            self:tween(e, Menu.itemFadeSpeed, { alpha = 0 })
        end)
    end

    if self.showingLogs then
        self:tween(self.logText, Menu.itemFadeSpeed, { alpha = 0 })
        self.logs(function(e)
            self:tween(e, Menu.itemFadeSpeed, { alpha = 0 })
        end)
    end

    self:tween(.3, { backgroundAlpha = 0 })
        :oncomplete(function()
            self:destroy()
            self.scene:quitPauseMenu()
        end)
end

-- START --

function Menu:onPressStart()
    local start = self.scene:findEntityWithTag("StartScene")
    local duration = start:hideLogo()

    self:hideCurrentItems()

    self.selectedItemLight.alpha = 0

    self.active = false

    self:delay(duration, function()
        self:showItems(self.mainItems)
        self.menuTree = {}
        self.active = true
    end)
end

-- MAIN MENU --

function Menu:onPressContinue()
    if self.pauseMenu then
        self:quitMenu()
    else
        self.scene:loadGame()
        self:hide()
    end
end

function Menu:onPressPlay()
    self.scene:startNewGame()
    self:hide()
end

function Menu:onPressPlayQuestion()
    self:showItems(self.newGameConfirmItems)
end

function Menu:onPressMinigames()
    self:showItems(self.minigamesItems)
end

function Menu:onPressDocuments()
    self:showItems(self.documentItems)
end

function Menu:onPressCredits()
    self.scene:goToCredits(true)
end

function Menu:onPressOptions()
    self:showItems(self.optionItems)
end

function Menu:onPressExit()
    if self.pauseMenu then
        self.scene:toMainMenu()
    else
        love.event.quit()
    end
end

-- MINIGAMES --

function Menu:onPressWaku()
    self:hide()
    self.scene:startWakuMinigame()
end

function Menu:onPressSpacerRacer()
    self:showUfoLevels()
end

function Menu:onPressSpecificSpacerRacerLevel()
    self:hide()
    self.scene:toUfoGame({ self.selectedUfoLevelNumber - 1 }, nil, true)
end

function Menu:onPressFighter()
    self:showItems(self.fightingGameItems)
end

function Menu:onPressFighterWithTraining()
    self:hide()
    self.scene:toFightingGame(true, true)
end

function Menu:onPressFighterWithoutTraining()
    self:hide()
    self.scene:toFightingGame(true, false)
end

-- DOCUMENTS --

function Menu:onPressBlueprints()
    self:showBlueprints()
end

function Menu:onPressSpecificBlueprint()
    if self.showingSpecificBlueprint then
        self:tween(self.specificBlueprint, .3, { x = WIDTH + 100 })
            :oncomplete(function() self.specificBlueprint:destroy() end)
        self.showingSpecificBlueprint = false
        return
    end

    if not self.selectedBlueprint.known then
        self.selectedBlueprint:shake(3, .3)
    else
        local blueprint = self:add(BlueprintDocument(self.selectedBlueprint.name))
        blueprint:center(WIDTH / 2, HEIGHT / 2)
        blueprint:setStart()
        blueprint.x = -WIDTH
        self:tween(blueprint, .3, { x = blueprint.start.x })
        self.specificBlueprint = blueprint
        self.showingSpecificBlueprint = true
    end
end

function Menu:onPressLogs()
    self:showLogs()
end

function Menu:onPressSpecificLog()
    if self.showingSpecificLog then
        self:tween(self.specificLog, .3, { x = WIDTH + 100 })
            :oncomplete(function() self.specificLog:destroy() end)
        self.showingSpecificLog = false
        return
    end

    if not self.selectedLog.known then
        self.selectedLog:shake(3, .3)
    else
        local log = self:add(LogDocument(self.selectedLog.name))
        log:center(WIDTH / 2, HEIGHT / 2)
        log:setStart()
        log.x = -WIDTH
        self:tween(log, .3, { x = log.start.x })
        self.specificLog = log
        self.showingSpecificLog = true
    end
end

-- OPTIONS --

function Menu:onPressControls()
    self:showItems(self.controlsItems)
end

function Menu:onPressScreen()
    self:showItems(self.screenItems)
end

function Menu:onPressAudio()
    self:showItems(self.audioItems)
end

-- CONTROLS OPTIONS --

function Menu:onPressControlsPeter()
    self:showItems(self.controlsPeterItems)
end

function Menu:onPressControlsPeterPlayer()
    self:toggleOption()

    local player1 = Save:get("settings.controls.peter.player1")
    Save:set("settings.controls.timon.player1", not player1)
end

function Menu:onPressControlsPeterRumble()
    self:toggleOption()

    local rumble = Save:get("settings.controls.peter.rumble")

    if rumble then
        local player1 = Save:get("settings.controls.peter.player1")
        local id = player1 and 1 or 2
        Input:rumble(id, .5, .5)
    end
end

function Menu:onPressControlsTimon()
    self:showItems(self.controlsTimonItems)
end

function Menu:onPressControlsTimonPlayer()
    self:toggleOption()

    local player1 = Save:get("settings.controls.timon.player1")
    Save:set("settings.controls.peter.player1", not player1)
end

function Menu:onPressControlsTimonRumble()
    self:toggleOption()

    local rumble = Save:get("settings.controls.timon.rumble")

    if rumble then
        local player1 = Save:get("settings.controls.timon.player1")
        local id = player1 and 1 or 2
        Input:rumble(id, .5, .5)
    end
end

-- SCREEN OPTIONS --

function Menu:onPressFullscreen()
    self:toggleOption()

    love.window.setFullscreen(Save:get("settings.screen.fullscreen"))
end

function Menu:onPressPixelPerfect()
    self:toggleOption()

    push:applySettings({ pixelperfect = Save:get("settings.screen.pixelperfect") })
    push:initValues()
end

function Menu:onPressPixel()
    self:toggleOption()

    push:applySettings({ pixel = Save:get("settings.screen.sharp") })
    push:initValues()
    libs.push:setFilter(Save:get("settings.screen.sharp") and "nearest" or "linear")
end

function Menu:onPressVsync()
    self:toggleOption()

    push:applySettings({ vsync = Save:get("settings.screen.vsync") and 1 or 0 })
    push:initValues()
end

-- AUDIO OPTIONS --

function Menu:onPressAudioOption(value)
    if not value then return end
    local path = self.selectedItem.conditionalContent.path
    local current = Save:get(path) or 100
    current = current + value * 5
    if current < 0 then current = 0 end
    if current > 100 then current = 100 end
    Save:set(path, current)
end

function Menu:onPressMaster(value)
    self:onPressAudioOption(value)

    local max = (Save:get("settings.audio.master") / 100) * (Save:get("settings.audio.music") / 100)
    Music.updateMaxVolume(max)

    max = (Save:get("settings.audio.master") / 100) * (Save:get("settings.audio.sfx") / 100)
    SFX.updateMaxVolume(max)
end

function Menu:onPressMusic(value)
    self:onPressAudioOption(value)

    local max = (Save:get("settings.audio.master") / 100) * (Save:get("settings.audio.music") / 100)
    Music.updateMaxVolume(max)
end

function Menu:onPressSFX(value)
    self:onPressAudioOption(value)

    local max = (Save:get("settings.audio.master") / 100) * (Save:get("settings.audio.sfx") / 100)
    SFX.updateMaxVolume(max)
end

-- PAUSE MENU --
function Menu:onPressBackToCentralHub()
    self:quitMenu()
    local players = self.scene:getPlayers()
    players:foreach(function(e, i)
        e.hurtable = false
        e.inControl = false
    end)

    self.scene:fadeOut(.5, function()
        self.scene:warpToLevel("Central_hub")
        players:foreach(function(e, i)
            e:onWarpIn(i)
            e.scale:set(0, 0)
        end)
    end)
end

return Menu
