local Credit = require("credit", ...)
local Sprite = require "base.sprite"
local Music = require "base.music"
local Text = require "base.text"
local Colors = require "base.colors"
local Scene = require "base.scene"
local Save = require "base.save"
local Input = require "base.input"

local Credits = Scene:extend("Credits")

function Credits:new(skippable)
    Credits.super.new(self)

    self:setBackgroundColor(23, 23, 23)

    self.skippable = skippable

    self.itemBuildHeight = 0
    self.durationList = {}
    self.itemList = {}
    self.functionList = {}
    self.currentItem = 1

    self.logo = self:add(Sprite(0, 0, "menu/logo", true))
    self.logo.scale:set(3)
    self.logo:center(WIDTH / 2, HEIGHT / 2 - 35)
    self.logo.toY = self.logo.y
    self.logo.y = HEIGHT * 1.5

    self.scrollDuration = .25

    self.creditsText = self:add(Text(WIDTH / 2, -74, "shoutouts", "bebas", 72))
    self.creditsText:setAlign("center", WIDTH)

    self.creditsCreationList = list()
    self.creditsCreationList:add(self.addSheepolution)
    self.creditsCreationList:add(self.addStriddums)
    self.creditsCreationList:add(self.addOnzichtbaard)
    self.creditsCreationList:add(self.addMakkeraad)
    self.creditsCreationList:add(self.addIsabel)
    self.creditsCreationList:add(self.addKoelka)
    self.creditsCreationList:add(self.addMoederwasbeer)
    self.creditsCreationList:add(self.addKatbeer)
    self.creditsCreationList:add(self.addFleur)
    self.creditsCreationList:add(self.addVampierusboy)
    self.creditsCreationList:add(self.addRoos)
    self.creditsCreationList:add(self.addVogeljongen)
    self.creditsCreationList:add(self.addPlaytesters)
    self.creditsCreationList:add(self.addSpecialThanks)
    self.creditsCreationList:add(self.addEndcard)

    self.music = Music("music", "credits")

    self.thisWasItText = self:add(Text(630, 100, "dit was het", "arial", 48))
    self.thisWasItText.visible = false

    self.emotionalMomentTimer = 60
end

function Credits:update(dt)
    if self.skippable and not self.fading then
        if Input:isAnyPressed() then
            self:fadeOut(.5, function()
                self.scene.scene:toIntro()
            end)
            self.fading = true
        end
    end

    if self.creditsCreationList then
        if #self.creditsCreationList > 0 then
            self.creditsCreationList:shift()(self)
        else
            for i, v in ipairs(self.itemList) do
                for j, w in ipairs(v) do
                    w.visible = false
                end
            end
            self.itemList[1][1].visible = true

            self:delay(2.5, function()
                self.thisWasItText:tween(.5, { x = 1000 }):ease("backin")
                self:delay(.3, function()
                    self.logo:tween(.5, { y = self.logo.toY }):ease("backout")
                    self.music:play("credits", false, true):setLooping(false)
                    self.camera:setWorld(0, -200, WIDTH, 100000)
                    self.camera:tweenToRelativePoint(0, -100, 1.9):delay(2.25)
                        :after(.3, { y = self.camera.y + HEIGHT }):ease("backout")
                        :wait(self.durationList[1], self.F:toNext())
                end)
            end)

            self.creditsCreationList = nil
        end
        return
    end

    if self.completed and not self.fading then
        if self.emotionalMomentTimer < -100 then
            if Input:isPressed("return", "c1_start", "c2_start") then
                self.completed = false
                self:fadeOut(1, function()
                    self.scene.scene:toIntro()
                end, false)
            end
        else
            self.emotionalMomentTimer = self.emotionalMomentTimer - dt
            if self.emotionalMomentTimer < 0 then
                self.fading = true
                self:fadeOut(1, function()
                    self.scene:goToSpeech()
                end)

                self.emotionalMomentText:write("Emotioneel momentje GO")
            elseif self.emotionalMomentTimer < 21 then
                self.emotionalMomentText.alpha = 1
                self.emotionalMomentText:write("Emotioneel momentje in " .. math.floor(self.emotionalMomentTimer))
            end
        end
    end

    Credits.super.update(self, dt)
end

function Credits:draw()
    Credits.super.draw(self)
    if self.video then
        love.graphics.draw(self.video, 0, 0, 0, .5, .5)
    end
end

function Credits:toNext()
    self.currentItem = self.currentItem + 1
    if self.currentItem > #self.itemList then
        self.completed = true
        return
    end

    self.camera:tweenToRelativePoint(0, HEIGHT, self.scrollDuration):ease("backout")
    self:delay(self.durationList[self.currentItem], self.F:toNext())
    for i, v in ipairs(self.itemList[self.currentItem]) do
        v.visible = true
    end

    if self.functionList[self.currentItem] then
        self:delay(self.scrollDuration, self.functionList[self.currentItem])
    end
end

function Credits:addCredit(name, code, credits, duration)
    self.itemBuildHeight = self.itemBuildHeight + 1
    local credit = self:add(Credit(HEIGHT * self.itemBuildHeight + HEIGHT / 2, name, code, credits))
    table.insert(self.durationList, duration or 5)
    table.insert(self.itemList, { credit })
    table.insert(self.functionList, false)
end

function Credits:addCreditNoPortrait(credits, duration)
    self.itemBuildHeight = self.itemBuildHeight + 1
    local credit = self:add(Credit(HEIGHT * self.itemBuildHeight + HEIGHT / 2, nil, nil, credits, true))
    table.insert(self.durationList, duration or 5)
    table.insert(self.itemList, { credit })
    table.insert(self.functionList, false)
end

function Credits:addItem(item, duration, func)
    self.itemBuildHeight = self.itemBuildHeight + 1
    item:centerY(HEIGHT * self.itemBuildHeight + HEIGHT / 2)
    table.insert(self.durationList, duration or 5)
    table.insert(self.itemList, { item })
    table.insert(self.functionList, func or false)

    return item
end

function Credits:addItems(items, duration, func)
    self.itemBuildHeight = self.itemBuildHeight + 1
    for i, v in ipairs(items) do
        if v.y ~= 0 then
            v:centerY(HEIGHT * self.itemBuildHeight + v.y)
        else
            v:centerY(HEIGHT * self.itemBuildHeight + HEIGHT / 2)
        end
    end
    table.insert(self.durationList, duration or 5)
    table.insert(self.itemList, items)
    table.insert(self.functionList, func or false)
end

function Credits:addSheepolution()
    self:addCredit("sheepolution", "SH - P0",
        "DIRECTOR, PRODUCER, DESIGNER\nCode, art, design, verhaal, dialogen\nMain Event", 5.5)

    local peter = self:add(Sprite(0, 0, "credits/items/sheepolution/peter", true))
    local timon = self:add(Sprite(0, 0, "credits/items/sheepolution/timon", true))
    peter:centerX(WIDTH / 2 - 100)
    timon:centerX(WIDTH / 2 + 110)
    timon.flip.x = true
    -- peter.offset.y = -100
    -- timon.offset.y = -100

    local tube_peter = self:add(Sprite(0, 0, "credits/items/sheepolution/tube_peter"))
    local tube_timon = self:add(Sprite(0, 0, "credits/items/sheepolution/tube_timon"))
    tube_peter:centerX(200)
    tube_timon:centerX(WIDTH - 200)
    tube_peter.offset.y = -100
    tube_timon.offset.y = -100

    local enemies = self:add(Sprite(0, 0, "credits/items/sheepolution/enemies"))
    enemies.offset.y = 0

    self:addItems({ peter, timon, tube_peter, tube_timon, enemies }, 5)

    local centaur = self:addItem(self:add(Sprite(0, 0, "credits/items/sheepolution/centaur", true)), 2.5)
    centaur:centerX(WIDTH / 2)

    local konkie = self:addItem(self:add(Sprite(0, 0, "credits/items/sheepolution/konkie", true)), 2.5)
    konkie:centerX(WIDTH / 2)

    local scientists = self:addItem(self:add(Sprite(0, 0, "credits/items/sheepolution/scientists")), 2.5)
    scientists:centerX(WIDTH / 2)
    -- self:addItem(self:add(Sprite(0, 0)), 3)
end

function Credits:addStriddums()
    self:addCredit("striddums", "SR - 1D",
        "ART DIRECTOR\nArt, design, ideeën", 4.3)

    local shop = self:add(Sprite(0, 0, "credits/items/striddums/shop", true))

    self:addItem(self:add(Sprite(0, 0, "credits/items/striddums/portraits")), 4.6)
    self:addItem(shop, 4.5, function()
        self:delay(.6, function()
            shop.anim:set("offer", true)
        end)
        self:delay(3, function()
            shop.anim:set("bought", true)
        end)
    end)

    self:addItem(self:add(Sprite(0, 0, "credits/items/striddums/fighters")), 4.5)

    local crying_peter = self:add(Sprite(0, 0, "minigames/roof/sad_peter", true))
    local crying_timon = self:add(Sprite(0, 0, "minigames/roof/sad_timon", true))

    crying_peter:centerX(WIDTH / 2 - 180)
    crying_timon:centerX(WIDTH / 2 + 200)

    crying_peter.offset.y = 25
    crying_timon.offset.y = -25
    crying_timon.flip.x = true

    self:addItems({ crying_peter, crying_timon }, 4, function()
        self:delay(.5, function()
            crying_peter.anim:set("cry", true)
            crying_timon.anim:set("cry", true)
        end)
    end)
end

function Credits:addOnzichtbaard()
    self:addCredit("onzichtbaard", "ON - Z8",
        "LEAD COMPOSER\nMuziek, ideeën",
        4.5)

    self:addItem(self:add(Sprite(0, 0, "credits/items/onzichtbaard/music1")), 4.5)
    self:addItem(self:add(Sprite(0, 0, "credits/items/onzichtbaard/music2")), 4.5)
end

function Credits:addMakkeraad()
    self:addCredit("makkeraad", "M4 - KR",
        "ARTIST, COMPOSER, DESIGNER\nArt, muziek, design, ideeën",
        6)

    self:addItem(self:add(Sprite(0, 0, "credits/items/makkeraad/backgrounds")), 4)
    self:addItem(self:add(Sprite(0, 0, "credits/items/makkeraad/gier_shop")), 4)
    self:addItem(self:add(Sprite(0, 0, "credits/items/makkeraad/music_and_cover")), 4)
    self.thisWasItText.visible = true
end

function Credits:addIsabel()
    self:addCredit("allerliefste_isabel", "1S - BL",
        "ARTIST\nBlueprints\nMet hulp van Specifiek_Reaus", 4.7)

    local blueprints = self:addItem(self:add(Sprite(0, 0, "credits/items/allerliefste_isabel/blueprints")), 4.7)
    blueprints:centerX(WIDTH / 2)
end

function Credits:addKoelka()
    self:addCredit("koelka", "KL - K4",
        "COMPOSER\nMuziek",
        4)

    self:addItem(self:add(Sprite(0, 0, "credits/items/koelka/music")), 4.3)
end

function Credits:addMoederwasbeer()
    self:addCredit("moederwasbeer", "MD - W8",
        "ARTIST\nGespierde Peter en Timon", 5)

    local peter_timon = self:addItem(self:add(Sprite(0, 0, "transition/fighter/peter_timon")), 6)
    peter_timon:setFilter("linear")
    peter_timon.scale:set(.5, .5)
    peter_timon.offset.x = -WIDTH / 2
end

function Credits:addKatbeer()
    self:addCredit("katbeer", "K7 - BR",
        "ARTIST\n\"Dode\" Peter/Timon cutscene", 4.5)

    self:addItem(self:add(Sprite(0, 0, "credits/items/katbeer/cutscenes")), 5.5)
end

function Credits:addFleur()
    self:addCredit("fleur4", "FL - 3R",
        "ARTIST\nFinale cutscene", 4.5)

    self:addItem(self:add(Sprite(0, 0, "credits/items/fleur/sunset")), 5.5)
end

function Credits:addVampierusboy()
    self:addCredit("vampierusboy", "V4-BY",
        "TROMPETTIST\nSkrale Skraper, Konkie level/boss, Credits\nIdeeën", 5.75)
end

function Credits:addRoos()
    self:addCredit("specifiek_reaus", "RO - O5",
        "BIOLOOG\nWAKU WAKU quizvragen\nSamen met haar medebiologen", 6)
end

function Credits:addVogeljongen()
    self:addCredit("vogeljongen", "V6 - JN",
        "VOICE ACTOR\nGier\nComposer van de Live om half vijf tune", 6)
end

function Credits:addPlaytesters()
    self:addCreditNoPortrait("PLAYTESTERS\nOnzichtbaard, striddums, Loezis, Mojosaman, Snekkie", 8.8)
end

function Credits:addSpecialThanks()
    self:addCreditNoPortrait(
        "SPECIAL THANKS\nPeter & Timon en de community\nEn iedereen die we gemist hebben, ontzettend bedankt!", 8.8)

    local heart = self:add(Sprite(0, 0, "credits/lekkerlief", true))

    table.insert(self.itemList[#self.itemList], heart)
    heart:centerX(WIDTH / 2)
    heart:centerY(HEIGHT * self.itemBuildHeight + HEIGHT / 2 + 150)
    heart.scale:set(4)
end

function Credits:addEndcard()
    local red = { Colors("peter", true) }
    local blue = { Colors("timon", true) }
    local white = { 1, 1, 1 }

    local game = Save:get("game")
    local stats = game.stats

    local main_event = self:add(Text(554, 115,
        { stats.main_event == "peter" and red or blue, stats.main_event or "Peter" }, "bebas_book", 32))
    local total_duration = self:add(Text(781, 115, _.clockHHMMSS(stats.time or 0), "bebas_book", 32))

    local blueprints = self:add(Text(554, 218, #Save:get("documents.blueprints") .. "/25", "bebas_book", 32))
    local euros = self:add(Text(781, 218, stats.euro, "bebas_book", 32))

    local death_counters = self:add(Text(554, 323,
        { red, game.deaths.peter or 0, white, "/", blue, game.deaths.timon or 0 },
        "bebas_book", 32))
    local papflappies = self:add(Text(781, 323,
        { red, game.health.peter.max - 2, white, "/", blue, game.health.timon.max - 2 }, "bebas_book", 32))

    local waku_waku1 = self:add(Text(554, 427, game.waku.questions .. " vragen", "bebas_book", 32))
    local waku_waku2 = self:add(Text(554, 459, { red, game.waku.peter, white, "/", blue, game.waku.timon },
        "bebas_book", 32))
    local waku_waku3 = self:add(Text(554, 491,
        game.waku.lifelines .. " hulplijn" .. (game.waku.lifelines == 1 and "" or "en"), "bebas_book", 32))

    local spacer_racer1 = self:add(Text(781, 427, game.spacer_racer.deaths.total .. " deaths", "bebas_book", 32))
    local spacer_racer2 = self:add(Text(781, 459, _.clockHMMSS(game.spacer_racer.time), "bebas_book", 32))

    self.emotionalMomentText = self:add(Text(140, 525, "Emotioneel momentje in 30", "bebas_book", 32))
    self.emotionalMomentText.alpha = 0

    self:addItems({
        main_event,
        total_duration,
        blueprints,
        euros,
        death_counters,
        papflappies,
        waku_waku1,
        waku_waku2,
        waku_waku3,
        spacer_racer1,
        spacer_racer2,
        self.emotionalMomentText,
        self:add(Sprite(0, 0, "credits/endcard"))
    }, 5)
end

return Credits
