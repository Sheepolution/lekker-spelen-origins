local Input = require "base.input"
local Sprite = require "base.sprite"
local Lamp = require "decoration.panda.lamp"
local Panda = require "characters.panda.panda"
local Cat = require "characters.panda.cat"
local Frog = require "characters.panda.frog"
local Fish = require "characters.panda.fish"
local Ant = require "characters.panda.ant"
local Peter = require "characters.panda.peter"
local Timon = require "characters.panda.timon"
local Enum = require "libs.enum"
local Music = require "base.music"
local FlagManager = require "flagmanager"
local Scene = require "base.scene"

local PandaRoom = Scene:extend("PandaRoom")

local direction_list = {
    "up",
    "left",
    "right",
    "down",
}

local clock_list = {
    "up",
    "right",
    "down",
    "left"
}

local GameType = Enum("Clefairy", "DDR", "Dance", "Freestyle")
PandaRoom.GameType = GameType

function PandaRoom:new(x, y, mapLevel)
    PandaRoom.super.new(self)
    self.x = x
    self.y = y
    self.mapLevel = mapLevel
end

function PandaRoom:done()
    self:setBackgroundAlpha(0)

    self.podium = self.mapLevel:add(Sprite(self.x + 64, self.y + 35, "bosses/panda/decoration/podium"))
    self.podium.z = 10
    self.screen = self.mapLevel:add(Sprite(self.x + 172, self.y + 30, "bosses/panda/decoration/screen"))
    self.screen:centerX(self.mapLevel.x + self.mapLevel.width / 2)
    self.screen.z = 10

    local default_volume = self.scene.music:getDefaultVolume()

    local song_right = self.scene.music:getSong("bosses/panda/danspauze_right")
    self.scene.music:play("bosses/panda/danspauze")
    local song = self.scene.music:getSong("bosses/panda/danspauze")
    song:seek(song_right:tell())
    self.scene.music:setVolume(default_volume, .5)
    self.scene.cutscenePausesMusic = false

    self.music = Music("music/bosses/panda", "country_roads", "echte_ster", "drum_loop")
    self.musicClefairy = Music("music/bosses/panda")
    for i = 1, 5 do
        self.musicClefairy:addSong("clefairy" .. i):setLooping(false)
    end

    self.cat = self:add(Cat())
    self.peter = self:add(Peter())
    self.timon = self:add(Timon())
    self.peter:danceNeutral()
    self.timon:danceNeutral()

    self.players = list({ self.peter, self.timon })
    self.players:takeControl()

    self.peter.visible = false
    self.timon.visible = false

    self.dancers = list()
    self.panda = self.dancers:add(self:add(Panda()))
    self.frog = self.dancers:add(self:add(Frog()))
    self.fish = self.dancers:add(self:add(Fish()))
    self.ant = self.dancers:add(self:add(Ant()))
    self.dancers:danceNeutral()

    self.cat.anim:set("play")

    self.clefairyTime = 10

    self.lamps = list()
    self.lamps:add(self.mapLevel:add(Lamp(self.x + 73, self.y + 43, false, false)))
    self.lamps:add(self.mapLevel:add(Lamp(self.x + 887, self.y + 43, true, false)))
    self.lamps:add(self.mapLevel:add(Lamp(self.x + 91, self.y + 442, false, true)))
    self.lamps:add(self.mapLevel:add(Lamp(self.x + 869, self.y + 442, true, true)))

    self.arrowSequence = list()
    self.arrowSprites = list()

    for i, v in ipairs(self.arrowSequence) do
        local arrow = self.arrowSprites:add(self:add(Sprite(235 + ((i - 1) % 6) * 90, 85 + 90 * math.floor((i - 1) / 6),
            "bosses/panda/arrow", true)))
        arrow.anim:set(v)
    end

    self.transparentArrowsPeter = list()
    self.transparentArrowsTimon = list()
    self.screenThings = list({ self.arrowSprites, self.transparentArrowsPeter, self.transparentArrowsTimon })

    for i = 1, 4 do
        local arrow = self:add(self.transparentArrowsPeter:add(Sprite(200, 60 + (i - 1) * 48,
            "bosses/panda/arrow_transparent",
            true)))
        arrow.anim:set(direction_list[i])
        arrow.visible = false

        arrow = self:add(self.transparentArrowsTimon:add(Sprite(715, 60 + (i - 1) * 48,
            "bosses/panda/arrow_transparent",
            true)))
        arrow.anim:set(direction_list[i])
        arrow.visible = false
    end

    self.currentArrow = 0

    self.timerShowArrows = step.new(.5)
    self.ddrSpawnNextArrowInterval = step.every(.5)
    self.delayBeforePlayersRepeat = step.after(2)
    self.delayBeforePlayersRepeat:finish()
    self.delayBeforePlayersRepeat(1)

    self.shownAllArrows = false

    self.clefairyStartDirections = list()
    self.clefairyPlayersRepeating = false

    self.mistakesMadePeter = 0
    self.mistakesMadeTimon = 0
    self.failedCount = 0

    self.registerInput = true
    self.danceDelays = list()

    self.useStencil = true

    self.angryLevel = 0

    self.danceLevel = 1
    self.danceLevelList = {
        4, 7, 6, 8
    }

    self.dansPauze = self:add(Sprite(0, 0, "bosses/panda/decoration/danspauze"))
    self.dansPauze:centerX(WIDTH / 2)
    self.dansPauze.y = 120
    self.dansPauze.timer = 0
    self.dansPauze.visible = false
    self.screenThings:add(self.dansPauze)

    self:doRandomDanceMoves()
    -- self:toDanceMode()
    -- self:initializeGame()
end

function PandaRoom:update(dt)
    PandaRoom.super.update(self, dt)
    if self.gameType == GameType.Clefairy then
        self:clefairyUpdate(dt)
    elseif self.gameType == GameType.DDR then
        self:ddrUpdate(dt)
    elseif self.gameType == GameType.Dance then
        self:danceUpdate(dt)
    elseif self.gameType == GameType.Freestyle then
        self:freestyleUpdate(dt)
    end
end

function PandaRoom:drawInCamera()
    PandaRoom.super.drawInCamera(self)

    -- love.graphics.stencil(function() love.graphics.rectangle("fill", 187, 0, WIDTH - 375, HEIGHT) end, "replace", 1)

    -- love.graphics.setStencilTest("greater", 0)

    if self.peter.dance then
        love.graphics.setColor(0, 0, .1, .5)
        love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    end

    if self.gameType == GameType.Clefairy and self.registerInput then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.arc("fill", WIDTH / 2, HEIGHT / 2 - 120, 70, -math.pi / 2,
            -math.pi / 2 - (math.pi * 2) * (self.clefairyTime / 10))
    end

    -- love.graphics.rectangle("fill")

    love.graphics.setColor(1, 1, 1, 1)
    if self.gameType == GameType.Freestyle then
        self.cat:draw()
        self.dancers:draw()
    end
    self.players:draw()

    love.graphics.stencil(function()
        love.graphics.rectangle("fill", 187, 0, WIDTH - 375, HEIGHT)
    end, "replace", 1)

    love.graphics.setStencilTest("greater", 0)

    self.screenThings:draw()

    love.graphics.setStencilTest()
end

function PandaRoom:initializeGame()
    local peter = self.scene:findEntityWithTag("Peter")
    local timon = self.scene:findEntityWithTag("Timon")
    if peter then
        peter.visible = false
        timon.visible = false
        peter.inControl = false
        timon.inControl = false
    end

    self.peter.visible = true
    self.timon.visible = true
    self.scene.ui.visible = false

    self.gameType = GameType.Clefairy
    self:clefairyStartGame()
end

function PandaRoom:onDanceMove(player, direction)
    if not self.registerInput then return end

    if self.gameType == GameType.Clefairy then
        self:clefairyOnDanceMove(player, direction)
    elseif self.gameType == GameType.DDR then
        self:ddrOnDanceMove(player, direction)
    elseif self.gameType == GameType.Dance then
        self:danceOnDanceMove(player, direction)
    end
end

function PandaRoom:onEndCutscene()
    if self.gameType == GameType.Clefairy then
        self:clefairyStartGame()
    elseif self.gameType == GameType.DDR then
        self:ddrStartGame()
    elseif self.gameType == GameType.Dance then
        self:danceStartGame()
    elseif self.gameType == GameType.Freestyle then
        self:freestyleStartGame()
    end
end

function PandaRoom:clefairyStartGame()
    self:clefairyRemoveAllArrows()
    self.timerShowArrows()
    self.delayBeforePlayersRepeat()
    self.clefairyStartDirections:clear()

    self.clefairyPlayersRepeating = false
    self.shownAllArrows = false
    self.registerInput = false

    self.circleStart = _.pick(clock_list)
    self.circleDirection = _.scoin()

    self.arrowStep = {
        Peter = 0,
        Timon = 0,
    }

    self.round = 1

    self.arrowSequence:clear()
    self.players:takeControl()

    self.music:play("drum_loop")
    self.cat.anim:set("play")

    self:clefairyAddArrows(4)
end

function PandaRoom:clefairyUpdate(dt)
    if self.timerShowArrows(dt) then
        self:clefairyShowNextArrow()
    end

    self.musicClefairy:update(dt)

    if self.shownAllArrows and not self.aboutToShowArrows then
        if self.delayBeforePlayersRepeat(dt) then
            local seconds = self.music:getSong():tell("seconds")
            self.aboutToShowArrows = true
            self:delay(1.2 - (seconds % 1.2), function()
                self.musicClefairy:play("clefairy" .. self.round)
                self:delay(1, function()
                    self.clefairyPlayersRepeating = true
                    self.registerInput = true
                    self.players:giveControl()
                    self:clefairyRemoveAllArrows()
                    self.clefairyTime = 10
                end)
            end)
            -- self.clefairyPlayersRepeating = true
            -- self.registerInput = true
            -- self.players:giveControl()
            -- self:clefairyRemoveAllArrows()
        end
    end

    if self.registerInput then
        self.clefairyTime = self.clefairyTime - dt
        if self.clefairyTime < 0 then
            self.clefairyTime = 0
            self:onMakingMistake()
        end
    end
end

function PandaRoom:clefairyOnDanceMove(player, direction)
    self.arrowStep[player.tag] = self.arrowStep[player.tag] + 1
    local step = self.arrowStep[player.tag]

    local mistake = self.arrowSequence[step] ~= direction

    if mistake then
        if player.tag:lower() == "peter" then
            self.mistakesMadePeter = self.mistakesMadePeter + 1
        else
            self.mistakesMadeTimon = self.mistakesMadeTimon + 1
        end

        local round_reverse = _.abs(6 - self.round)
        local allowed_mistakes = _.floor(self.failedCount / 5)
        local extra = self.failedCount % 5

        if round_reverse <= extra then
            allowed_mistakes = allowed_mistakes + 1
        end

        if self.mistakesMadePeter <= allowed_mistakes and self.mistakesMadeTimon <= allowed_mistakes then
            mistake = false
        end
    end

    if not mistake then
        if step == #self.arrowSequence then
            player:takeControl()
            if self.arrowStep.Peter == #self.arrowSequence and self.arrowStep.Timon == #self.arrowSequence then
                self.registerInput = false
                self:delay(.5, function()
                    self.timerShowArrows()
                    self.clefairyPlayersRepeating = false
                    self.shownAllArrows = false
                    self.currentArrow = 0
                    self.players:danceNeutral()
                    self.arrowStep = {
                        Peter = 0,
                        Timon = 0,
                    }

                    if #self.arrowSequence == 12 then
                        self:clefairyFinish()
                    else
                        self.mistakesMadePeter = 0
                        self.mistakesMadeTimon = 0
                        self.round = self.round + 1
                        self:clefairyAddArrows()
                    end
                end)
            end
        end
    else
        self:onMakingMistake()
        Input:rumble(self.scene[player.tag:lower()].controllerId, .1, .25)
    end
end

function PandaRoom:onMakingMistake()
    self.registerInput = false
    self.players:takeControl()

    self.clefairyPlayersRepeating = false

    self.music:stop(.5)
    self.musicClefairy:stop(.5)

    self.mistakesMadePeter = 0
    self.mistakesMadeTimon = 0
    self.failedCount = self.failedCount + 1

    self:delay(.5, function()
        self.cat.anim:set("idle")
        self.angryLevel = _.min(self.angryLevel + 1, 6)
        self.scene:startCutscene("panda.wrong" .. self.angryLevel, function() self:onEndCutscene() end)
    end)
end

function PandaRoom:clefairyAddArrows(amount)
    local increment = amount or 2
    for i = 1, increment do
        if #self.arrowSequence % 4 == 0 then
            -- TODO: Make it so that it can't use a start direction that has already been used
            local pick
            repeat
                pick = _.pick(clock_list)
            until not self.clefairyStartDirections:contains(pick)

            self.clefairyStartDirections:add(pick)
            self.circleStart = pick
            self.circleDirection = _.scoin()
        end
        -- local direction
        -- repeat
        --     direction = _.pick(direction_list)
        -- until #self.arrowSequence == 0 or direction ~= self.arrowSequence[#self.arrowSequence]

        local index = table.index_of(clock_list, self.circleStart)
        local direction = table.wrap(clock_list, index + (#self.arrowSequence % 4) * self.circleDirection)

        self.arrowSequence:add(direction)
    end
end

function PandaRoom:clefairyShowNextArrow()
    if self.shownAllArrows then return end

    if self.currentArrow == #self.arrowSequence then
        self.shownAllArrows = true
        -- self:delay(1, function()
        --     self.musicClefairy:play("clefairy" .. self.round)
        -- end)
        self.delayBeforePlayersRepeat()
        self.aboutToShowArrows = false
        self.dancers:danceNeutral()
        return
    end

    self.currentArrow = self.currentArrow + 1
    local i = self.currentArrow
    local direction = self.arrowSequence[self.currentArrow]

    local arrow = self.arrowSprites:add(self:add(Sprite(235 + ((i - 1) % 6) * 90, 85 + 90 * math.floor((i - 1) / 6),
        "bosses/panda/arrow", true)))

    arrow.anim:set(direction)
    arrow.scale:set(0)
    self:tween(arrow.scale, .2, { x = 1, y = 1 }):ease("backout")
    self.dancers:danceTo(direction)
    self.lamps:randomColor()
end

function PandaRoom:clefairyRemoveAllArrows()
    self.currentArrow = 0
    self.arrowSprites:destroy()
    self.arrowSprites:clear()
    self.playing = true
end

function PandaRoom:clefairyFinish()
    self.gameType = GameType.DDR
    self.scene:startCutscene("panda.ddr", function() self:onEndCutscene() end)

    self.angryLevel = 0
    self.failedCount = 0

    self.music:stop(2)
    self.musicClefairy:stop()
    self.cat.anim:set("idle")
end

function PandaRoom:ddrStartGame()
    self.transparentArrowsPeter(function(e) e.visible = true end)
    self.transparentArrowsTimon(function(e) e.visible = true end)

    self.music:stop()
    self.music:play("echte_ster")
    self.cat.anim:set("play")
    self.music:getSong():setLooping(false)

    self.players:giveControl()
    self.registerInput = true

    self.currentArrow = 0

    self.arrowSequence:clear()
    self:ddrAddArrows(32)
    self:ddrAddArrows(8, true)
    self:ddrAddArrows(9)
    self:ddrAddArrows(3, true)
    self:ddrAddArrows(1)
    self:ddrAddArrows(1, true)
    self:ddrAddArrows(3)
    self:ddrAddArrows(7, true)
    self:ddrAddArrows(32)

    self.ddrArrowEvent = self:event(function()
        self.coil.wait(2.2)
        self.ddrSpawnNextArrowInterval()
        for i, v in ipairs(self.arrowSequence) do
            self:ddrShowNextArrow()
            self.ddrSpawnNextArrow = self.coil.callback()
            self.coil.wait(self.ddrSpawnNextArrow)
        end
        self.coil.wait(3)
    end, nil, 1, function()
        self:ddrFinish()
    end)
end

function PandaRoom:ddrUpdate(dt)
    if self.ddrSpawnNextArrowInterval(dt) then
        if self.ddrSpawnNextArrow then
            self.ddrSpawnNextArrow()
            self.ddrSpawnNextArrow = nil
        end
    end

    for i, v in _.ripairs(self.arrowSprites) do
        if v.x > WIDTH - 160 or v.x < 170 then
            local player = v.x < 170 and "peter" or "timon"

            if player == "Peter" then
                self.mistakesMadePeter = self.mistakesMadePeter + 1
                if self.mistakesMadePeter < self.failedCount / 4 then
                    self.arrowSprites:remove_value(v)
                    break
                end
            else
                self.mistakesMadeTimon = self.mistakesMadeTimon + 1
                if self.mistakesMadeTimon < self.failedCount / 4 then
                    self.arrowSprites:remove_value(v)
                    break
                end
            end

            self.ddrArrowEvent:stop()
            self.arrowSprites:clear()
            self.danceDelays:stop()
            self.danceDelays:clear()
            self:onMakingMistake()
            break
        end
    end
    -- if self.timerShowArrows(dt) then
    --     self:ddrShowNextArrow()
    -- end

    -- if self.shownAllArrows then
    --     if self.delayBeforePlayersRepeat(dt) then
    --         self.clefairyPlayersRepeating = true
    --         self.registerInput = true
    --         self.players:giveControl()
    --         self:clefairyRemoveAllArrows()
    --     end
    -- end
end

function PandaRoom:ddrOnDanceMove(player, direction)
    local arrow
    local index = table.indexOf(direction_list, direction)
    if player.tag == "Peter" then
        arrow = self.transparentArrowsPeter[index]
    else
        arrow = self.transparentArrowsTimon[index]
    end

    arrow.scale:set(1.4)
    self:tween(arrow.scale, .1, { x = 1, y = 1 })

    local arrows = self.arrowSprites:filter(function(e)
        return e.player == player.tag and e:overlapsX(arrow) and
            not e.triggered
    end)
    if #arrows == 0 and #self.arrowSprites > 0 then
        if player.tag == "Peter" then
            self.mistakesMadePeter = self.mistakesMadePeter + 1
            if self.mistakesMadePeter < self.failedCount / 4 then
                goto continue
            end
        else
            self.mistakesMadeTimon = self.mistakesMadeTimon + 1
            if self.mistakesMadeTimon < self.failedCount / 4 then
                goto continue
            end
        end

        self.ddrArrowEvent:stop()
        self.arrowSprites(function(e) e.moveTween:stop() end)
        self.arrowSprites:clear()
        self.danceDelays:stop()
        self.danceDelays:clear()
        self:onMakingMistake()
        return
    end

    local a, d = arrows:find_min(function(e) return arrow:getDistanceX(e) end)

    if d < 15 then
        if a.direction == direction then
            a.singleColor = { 255, 255, 255 }
            a.moveTween:stop()
            a.triggered = true
            self:tween(a.scale, .2, { x = 0, y = 0 }):ease("backin")
                :oncomplete(function()
                    a:destroy()
                    self.arrowSprites:removeValue(a)
                end)
        else
            if player.tag == "Peter" then
                self.mistakesMadePeter = self.mistakesMadePeter + 1
                if self.mistakesMadePeter < self.failedCount / 4 then
                    goto continue
                end
            else
                self.mistakesMadeTimon = self.mistakesMadeTimon + 1
                if self.mistakesMadeTimon < self.failedCount / 4 then
                    goto continue
                end
            end

            self.ddrArrowEvent:stop()
            self.arrowSprites(function(e) e.moveTween:stop() end)
            self.arrowSprites:clear()
            self.danceDelays:stop()
            self.danceDelays:clear()
            self:onMakingMistake()
            Input:rumble(self.scene[player.tag:lower()].controllerId, .1, .25)
        end
    end

    ::continue::
end

function PandaRoom:ddrShowNextArrow()
    self.currentArrow = self.currentArrow + 1

    if self.currentArrow > #self.arrowSequence then
        return
    end

    local direction = self.arrowSequence[self.currentArrow]
    if direction == "empty" then
        self.danceDelays:add(self:delay(1.78,
            function()
                self.lamps:randomColor()
                self.lamps:randomAngle()
            end))
        return
    end

    local index = table.indexOf(direction_list, direction)

    local arrow = self.arrowSprites:add(Sprite(0, 60 + (index - 1) * 48, "bosses/panda/arrow", true))
    arrow.anim:set(direction)
    arrow.direction = direction
    arrow:centerX(WIDTH / 2)
    arrow.player = "Peter"
    arrow.moveTween = self:tween(arrow, 3, { x = arrow.width / 2 }):ease("linear")

    arrow = self.arrowSprites:add(Sprite(0, 60 + (index - 1) * 48, "bosses/panda/arrow", true))
    arrow.anim:set(direction)
    arrow.direction = direction
    arrow:centerX(WIDTH / 2)
    arrow.player = "Timon"
    arrow.moveTween = self:tween(arrow, 3, { x = WIDTH - 65 }):ease("linear")

    self.danceDelays:add(self:delay(1.78,
        function()
            self.lamps:randomColor()
            self.lamps(function(e) e.angle = 0 end)
            self.dancers["dance" .. _.title(direction)](self.dancers)
        end))
end

function PandaRoom:ddrAddArrows(amount, empty)
    for i = 1, amount do
        if empty then
            self.arrowSequence:add("empty")
        else
            local direction
            repeat
                direction = _.pick(direction_list)
            until #self.arrowSequence == 0 or direction ~= self.arrowSequence[#self.arrowSequence]

            self.arrowSequence:add(direction)
        end
    end
end

function PandaRoom:ddrFinish()
    self.transparentArrowsPeter(function(e) e.visible = false end)
    self.transparentArrowsTimon(function(e) e.visible = false end)

    self.players:takeControl()

    self.cat.anim:set("idle")

    self.angryLevel = 0
    self.failedCount = 0

    self.scene:startCutscene("panda.dance", function()
        self.gameType = GameType.Dance
        self:onEndCutscene()
    end)
end

function PandaRoom:danceStartGame()
    self.transparentArrowsPeter(function(e) e.visible = false end)
    self.transparentArrowsTimon(function(e) e.visible = false end)

    self.delayBeforePlayersRepeat:set(1.5)

    self.music:stop()
    self.cat.anim:set("play")
    self.music:play("country_roads")
    self.music:getSong():setLooping(false)

    self.players:takeControl()
    self.registerInput = false

    self.gameStarted = false


    self:delay(3.5, function()
        self.clefairyPlayersRepeating = false
        self.shownAllArrows = false
        self.playersAreDancing = false

        self:clefairyRemoveAllArrows()
        self.timerShowArrows()
        self.delayBeforePlayersRepeat()
        self.clefairyStartDirections:clear()

        self.arrowSequence:clear()

        self.danceLevel = _.max(1, self.danceLevel - 3)

        self.gameStarted = true

        self:clefairyAddArrows(self.danceLevelList[self.danceLevel])
    end)
end

function PandaRoom:danceUpdate(dt)
    if not self.gameStarted then return end

    if self.timerShowArrows(dt) then
        self:clefairyShowNextArrow()
    end

    if self.shownAllArrows and not self.playersAreDancing and not self.aboutToShowArrows then
        if self.delayBeforePlayersRepeat(dt) then
            self.delayBeforePlayersRepeat:set(3)
            local seconds = self.music:getSong():tell("seconds")
            self.aboutToShowArrows = true
            self:delay(.75 - (seconds % .5), function()
                self.registerInput = true
                self.players:giveControl()
                self:clefairyRemoveAllArrows()
                self:danceStartDanceSequence()
            end)
        end
    end

    for i, v in ipairs(self.arrowSprites) do
        if v.x > WIDTH - 160 or v.x < 170 then
            local player = v.x < 170 and "peter" or "timon"

            if player == "Peter" then
                self.mistakesMadePeter = self.mistakesMadePeter + 1
                if self.mistakesMadePeter < self.failedCount / 4 then
                    self.arrowSprites:remove_value(v)
                    break
                end
            else
                self.mistakesMadeTimon = self.mistakesMadeTimon + 1
                if self.mistakesMadeTimon < self.failedCount / 4 then
                    self.arrowSprites:remove_value(v)
                    break
                end
            end

            self.ddrArrowEvent:stop()
            self.arrowSprites:clear()
            self.danceDelays:stop()
            self.danceDelays:clear()
            self:onMakingMistake()
            break
        end
    end
end

function PandaRoom:danceStartDanceSequence()
    self.transparentArrowsPeter(function(e) e.visible = true end)
    self.transparentArrowsTimon(function(e) e.visible = true end)
    self.currentArrow = 0
    self.playersAreDancing = true
    self.ddrArrowEvent = self:event(function()
        for i, v in ipairs(self.arrowSequence) do
            self.coil.wait(.5)
            self:danceShowNextArrow()
        end
        self.coil.wait(3)
    end, nil, 1, function()
        self.danceLevel = self.danceLevel + 1
        if self.danceLevel > #self.danceLevelList then
            self:danceFinish()
            return
        end
        self.arrowSequence:clear()
        self.clefairyStartDirections:clear()
        self:clefairyAddArrows(self.danceLevelList[self.danceLevel])
        self.shownAllArrows = false
        self.playersAreDancing = false
        self.currentArrow = 0
        self.timerShowArrows()
        self.transparentArrowsPeter(function(e) e.visible = false end)
        self.transparentArrowsTimon(function(e) e.visible = false end)
    end)
end

function PandaRoom:danceShowNextArrow()
    self.currentArrow = self.currentArrow + 1

    if self.currentArrow > #self.arrowSequence then
        return
    end

    local direction = self.arrowSequence[self.currentArrow]
    local index = table.indexOf(direction_list, direction)

    local bar_peter = self.arrowSprites:add(Sprite(0, 55, "bosses/panda/bar"))
    bar_peter.direction = direction
    bar_peter:centerX(WIDTH / 2)
    bar_peter.player = "Peter"
    bar_peter.moveTween = self:tween(bar_peter, 3, { x = bar_peter.width / 2 }):ease("linear")
    bar_peter.isBar = true
    bar_peter.alpha = .5

    local bar_timon = self.arrowSprites:add(Sprite(0, 55, "bosses/panda/bar"))
    bar_timon.direction = direction
    bar_timon:centerX(WIDTH / 2)
    bar_timon.player = "Timon"
    bar_timon.moveTween = self:tween(bar_timon, 3, { x = WIDTH - 65 }):ease("linear")
    bar_timon.isBar = true
    bar_timon.alpha = .5

    local arrow = self.arrowSprites:add(Sprite(0, 60 + (index - 1) * 48, "bosses/panda/arrow", true))
    arrow.anim:set(direction)
    arrow.direction = direction
    arrow:centerX(WIDTH / 2)
    arrow.player = "Peter"
    arrow.moveTween = self:tween(arrow, 3, { x = arrow.width / 2 }):ease("linear")
    arrow.visible = false
    arrow.bar = bar_peter

    arrow = self.arrowSprites:add(Sprite(0, 60 + (index - 1) * 48, "bosses/panda/arrow", true))
    arrow.anim:set(direction)
    arrow.direction = direction
    arrow:centerX(WIDTH / 2)
    arrow.player = "Timon"
    arrow.moveTween = self:tween(arrow, 3, { x = WIDTH - 65 }):ease("linear")
    arrow.visible = false
    arrow.bar = bar_timon

    self.danceDelays:add(self:delay(1.78,
        function()
            self.lamps:randomColor()
            self.dancers["dance" .. _.title(direction)](self.dancers)
        end))
end

function PandaRoom:danceOnDanceMove(player, direction)
    local arrow
    local index = table.indexOf(direction_list, direction)
    if player.tag == "Peter" then
        arrow = self.transparentArrowsPeter[index]
    else
        arrow = self.transparentArrowsTimon[index]
    end

    arrow.scale:set(1.4)
    self:tween(arrow.scale, .1, { x = 1, y = 1 })

    local arrows = self.arrowSprites:filter(function(e)
        return e.player == player.tag and
            e:overlapsX(arrow) and
            not e.isBar
            and not e.triggered
    end)
    if #arrows == 0 then
        if player.tag == "Peter" then
            self.mistakesMadePeter = self.mistakesMadePeter + 1
            if self.mistakesMadePeter < self.failedCount / 2 then
                goto continue
            end
        else
            self.mistakesMadeTimon = self.mistakesMadeTimon + 1
            if self.mistakesMadeTimon < self.failedCount / 2 then
                goto continue
            end
        end

        self.ddrArrowEvent:stop()
        self.arrowSprites(function(e) e.moveTween:stop() end)
        self.arrowSprites:clear()
        self.danceDelays:stop()
        self.danceDelays:clear()
        self:onMakingMistake()
        return
    end

    local a, d = arrows:find_min(function(e) return arrow:getDistanceX(e) end)

    if d < 15 then
        if a.direction == direction then
            a.singleColor = { 255, 255, 255 }
            a.moveTween:stop()
            a.visible = true
            a.triggered = true
            a.bar.moveTween:stop()
            a.bar:destroy()
            self.arrowSprites:removeValue(a.bar)
            self:tween(a.scale, .2, { x = 0, y = 0 }):ease("backin")
                :oncomplete(function()
                    a:destroy()
                    self.arrowSprites:removeValue(a)
                end)
        else
            if player.tag == "Peter" then
                self.mistakesMadePeter = self.mistakesMadePeter + 1
                if self.mistakesMadePeter < self.failedCount / 2 then
                    arrows:remove_value(a)
                    goto continue
                end
            else
                self.mistakesMadeTimon = self.mistakesMadeTimon + 1
                if self.mistakesMadeTimon < self.failedCount / 2 then
                    arrows:remove_value(a)
                    goto continue
                end
            end

            self.ddrArrowEvent:stop()
            self.arrowSprites:clear()
            self.danceDelays:stop()
            self.danceDelays:clear()
            self:onMakingMistake()
            Input:rumble(self.scene[player.tag:lower()].controllerId, .1, .25)
        end
    end

    ::continue::
end

function PandaRoom:danceFinish()
    self.transparentArrowsPeter(function(e) e.visible = false end)
    self.transparentArrowsTimon(function(e) e.visible = false end)

    self.cat.anim:set("idle")

    self.players:takeControl()
    self:delay(1, function()
        self.cat.anim:set("idle")
        self.scene:startCutscene("panda.freestyle", function()
            self.gameType = GameType.Freestyle
            self:onEndCutscene()
        end)
    end)
end

function PandaRoom:freestyleStartGame()
    self.music:play("danspauze", nil, true)
        :setLooping(false)
    self:doRandomDanceMoves()
    self.players:giveControl()
    self.dansPauze.visible = true
    self.dansBaseZoom = 2

    self:delay(40, function()
        self.randomDanceMovesEvent:stop()
        self.players:takeControl()
        self.scene:startCutscene("panda.finish")
        FlagManager:set(Enums.Flag.defeatedPanda, true)
        FlagManager:set(Enums.Flag.cutscenePandaIntro, true)
        self:delay(3, function()
            self.music:clear()
            self.scene.music:play("bosses/panda/danspauze")
            self.scene.ui.visible = true
            self.scene.ui:show()
        end)
    end)

    self:event(function()
        local camera = self.scene.camera
        self.coil.wait(7.7)
        camera:zoomTo(3)
        local x, y = self.scene:getLevel():center()
        camera:moveToPoint(x - 200, y)
        self.coil.wait(.1)
        camera:tweenToRelativePoint(450, 0, 4):ease("linear")
        self.coil.wait(4.7)
        camera:moveToRelativePoint(-150, 100)
        self.coil.wait(.1)
        camera:tweenToRelativePoint(-200, 0, 3):ease("linear")
        self.coil.wait(3.7)
        camera:moveToRelativePoint(220, -50)
        self.dansCamera = true
        self.coil.wait(4)
        camera:moveToRelativePoint(-220, 30)
        self.coil.wait(4)
        camera:moveToRelativePoint(350, -50)
        self.dansBaseZoom = 4
        self.coil.wait(3.8)
        camera:moveToRelativePoint(-450, -20)
        self.coil.wait(3.8)
        camera:moveToPoint(x, y - 200)
        self.dansBaseZoom = 2
        self.coil.wait(2.4)
        camera:tweenToRelativePoint(0, 200, 1):ease("quadout")
    end, nil, 1)
end

function PandaRoom:freestyleUpdate(dt)
    self.dansPauze.timer = self.dansPauze.timer + dt
    self.dansPauze.angle = _.cos(self.dansPauze.timer * PI) / 4

    if self.dansCamera then
        self.scene.camera.camera.angle = _.cos(self.dansPauze.timer * PI) / 8
        self.scene.camera.zoom = self.dansBaseZoom + _.sin(self.dansPauze.timer * PI * 2) / 4
    end
end

function PandaRoom:doRandomDanceMoves()
    self.cat.anim:set("play")
    self.randomDanceMovesEvent = self:event(function()
        self.dancers:doRandomDanceMove()
        self.lamps:randomColor()
        self.dansPauze.scale:set(1.1)
        self:tween(self.dansPauze.scale, .2, { x = 1, y = 1 })
    end, .5)
end

function PandaRoom:toDanceMode()
    self.peter.dance = true
    self.timon.dance = true
    self.peter.anim:set("neutral_dance")
    self.timon.anim:set("neutral_dance")
    self.lamps(function(e)
        e.light.alpha = .2
        e.angleAround = true
    end)
end

return PandaRoom
