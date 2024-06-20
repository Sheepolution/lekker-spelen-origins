local SFX = require "base.sfx"
local Save = require "base.save"
local websocket = require "libs.websocket"
local Colors = require "base.colors"
local Asset = require "base.asset"
local Text = require "base.text"
local Scene = require "base.scene"

local Waku = Scene:extend("Waku")

local Point = require "base.point"
local Sprite = require "base.sprite"

local questions = require "data.waku_questions"
local abc = { "A", "B", "C" }

function Waku:new(scene)
    Waku.super.new(self)

    self.scene = scene

    self:setBackgroundAlpha(0)
    self.useStencil = true
    self:setFilter("linear", "linear")

    self.text = list()

    self.questionNumber = self.text:add(self:add(Text(WIDTH / 2, 70, "Vraag #1", "BebasNeue", 28)))
    self.questionNumber:setAlign("center", WIDTH)

    self.questionText = self.text:add(self:add(Text(WIDTH / 2, 112,
        "Welk dier is geen knaagdier?",
        "BebasNeue", 36)))
    self.questionText:setAlign("center", WIDTH - 32 * 4)
    self.questionText:setFilter("linear", "linear")

    self.answerOptionA = self.text:add(self:add(
        Text(200, 220, "A: Eekhoorn", "bebas_regular", 36)))
    self.answerOptionB = self.text:add(self:add(
        Text(200, 260, "B: Bever", "bebas_regular", 36)))
    self.answerOptionC = self.text:add(self:add(
        Text(200, 300, "C: Konijn", "bebas_regular", 36)))
    self.answerOptionList = list({ self.answerOptionA, self.answerOptionB, self.answerOptionC })

    self.answerButtonA = self.text:add(Text(321, 395, "A", "BebasNeue", 64))
    self.answerButtonB = self.text:add(Text(481, 395, "B", "BebasNeue", 64))
    self.answerButtonC = self.text:add(Text(641, 395, "C", "BebasNeue", 64))
    self.answerButtonList = list({ self.answerButtonA, self.answerButtonB, self.answerButtonC })
    self.answerButtonList(function(e)
        e:setAlign("center", 160)
        e:setFilter("linear", "linear")
    end)

    self.pointsRequired = 20
    self.pointsText = self.text:add(self:add(Text(80, 70, "Punten: 0/" .. self.pointsRequired, "BebasNeue", 28)))

    self.pointsIndividualText = self.text:add(self:add(Text(WIDTH - 80, 70,
        { { Colors("peter", true) }, "0", { 1, 1, 1 }, "/", { Colors("timon", true) }, "0" }, "BebasNeue", 28)))
    self.pointsIndividualText:setAlign("right", 200)

    self.clockTime = self.text:add(Text(830, 370, "30", "BebasNeue", 72))
    self.clockTime:setAlign("center", 200)
    self.arc = Point(830, 410)

    self.timer = 30
    self.countDown = false

    self.maxTextWidth = 785

    self.text:setFilter("linear", "linear")
    self:centerAnswerOptions()

    self.lifelineCount = 0

    self.lifelineIconFifty = self:add(Sprite(118, 364, "bosses/computer/waku/lifeline_fifty"))
    self.lifelineIconAudience = self:add(Sprite(160, 364, "bosses/computer/waku/lifeline_audience"))
    self.lifelineIconComputer = self:add(Sprite(202, 364, "bosses/computer/waku/lifeline_computer"))
    self.lifelineIcons = list({ self.lifelineIconFifty, self.lifelineIconAudience, self.lifelineIconComputer })

    self.lifelineIconFiftyBig = self:add(Sprite(304, 353, "bosses/computer/waku/lifeline_fifty"))
    self.lifelineIconAudienceBig = self:add(Sprite(464, 353, "bosses/computer/waku/lifeline_audience"))
    self.lifelineIconComputerBig = self:add(Sprite(624, 353, "bosses/computer/waku/lifeline_computer"))
    self.lifelineIconsBig = list({ self.lifelineIconFiftyBig, self.lifelineIconAudienceBig, self.lifelineIconComputerBig })
    self.lifelineIconsBig(function(e) e.scale:set(2) end)
    self.lifelineIconsBig({ alpha = 0 })

    self.chatPercentages = { 0, 0, 0 }
    self.answerButtonA = self.text:add(self:add(Text(321, 355, "42%", "BebasNeue", 36)))
    self.answerButtonB = self.text:add(self:add(Text(481, 355, "11%", "BebasNeue", 36)))
    self.answerButtonC = self.text:add(self:add(Text(641, 355, "47%", "BebasNeue", 36)))
    self.chatPercentagesTexts = list({ self.answerButtonA, self.answerButtonB, self.answerButtonC })
    self.chatPercentagesTexts(function(e)
        e:setAlign("center", 160)
        e.alpha = 0
    end)

    self:generateAudioShuffles()

    self.answerValues = {
        peter = { 0, 0, 0 },
        timon = { 0, 0, 0 },
    }

    self.questionCount = 0
    self.points = 0
    self.pointsIndividual = {
        peter = 0,
        timon = 0
    }

    self.lifelineMode = false
    self.alreadyActivatedLifeline = false
    self.lifelineCooldowns = { 0, 0, 0 }

    self.buttonStandedOnBeforeStart = {
        peter = 0,
        timon = 0
    }

    self.seen = {
        {},
        {},
        {},
        {},
        {},
    }

    self.seenChatters = {}
    self.useFakeAudience = false
    self.switchToFakeTimer = step.new(2)
    self.fakeAudienceTimer = step.new(.05, .2)
    self.fakeAudienceWeighted = { 6, 8, 10 }

    self:nextQuestion()
end

function Waku:update(dt)
    if self.askingChat then
        if self.client then
            self.client:update(dt)
        end
        if self.switchToFakeTimer(dt) then
            self.useFakeAudience = true
        end

        if self.useFakeAudience then
            if self.fakeAudienceTimer(dt) then
                self:onReceivingAudienceAnswer(_.weightedchoice(self.fakeAudienceWeighted))
            end
        end
    end

    if self.countDown then
        self.timer = self.timer - dt

        if self.timer <= 0 then
            self.timer = 0
            self:onTimeRunningOut()
            goto continue
        end


        for k, v in pairs(self.answerValues) do
            local switch = self.buttonStandedOnBeforeStart[k]

            if switch and switch ~= v.standingOn then
                self.buttonStandedOnBeforeStart[k] = nil
            end

            if not self.buttonStandedOnBeforeStart[k] then
                for i, w in ipairs(v) do
                    if w > 0 and v.standingOn ~= i then
                        v[i] = w - dt * 2
                        if v.filled == i then
                            v.filled = nil
                        end
                        if v[i] < 0 then
                            v[i] = 0
                        end
                    end
                end

                if not v.filled then
                    if v.standingOn then
                        local i = v.standingOn
                        if not self.lifelineMode or self.lifelineCooldowns[i] == 0 then
                            v[i] = v[i] + dt * .75
                        end
                        if v[i] >= 1 then
                            v[i] = 1
                            v.filled = i
                            if self.answerValues.peter.filled and self.answerValues.timon.filled then
                                self:onBothFilled()
                                goto continue
                            end
                        end
                    end
                end
            end
        end

        self.answerValues.peter.standingOn = nil
        self.answerValues.timon.standingOn = nil
        ::continue::
        self.clockTime:write(math.ceil(self.timer))
    end

    Waku.super.update(self, dt)
end

function Waku:drawInCamera()
    Waku.super.drawInCamera(self)
    self:drawClock()
end

function Waku:drawClock()
    love.graphics.setColor(1, 1, 1)

    self.clockTime:setColor(255, 255, 255)
    self.clockTime:draw()

    local function drawArc()
        love.graphics.arc("fill", self.arc.x, self.arc.y, 45, PI * 3 / 2, PI * 3 / 2 - PI * 2 * (self.timer / 30), 50)
        love.graphics.arc("line", self.arc.x, self.arc.y, 45, PI * 3 / 2, PI * 3 / 2 - PI * 2 * (self.timer / 30), 50)
    end

    love.graphics.setLineStyle("smooth")
    love.graphics.stencil(drawArc, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.setColor(1, 1, 1)

    drawArc()

    self.clockTime:setColor(0, 0, 0)
    self.clockTime:draw()
    love.graphics.setStencilTest()

    ------

    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(2)
    for k, v in pairs(self.answerValues) do
        local offset = 0
        if k == "peter" then
            love.graphics.setColor(Colors("peter", true))
        else
            love.graphics.setColor(Colors("timon", true))
            offset = 32
        end

        for i, w in ipairs(v) do
            love.graphics.rectangle("fill", 288 + offset + (i - 1) * 160, 470 - 70 * w, 32, 70 * w)
        end
    end

    for i = 0, 2 do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 288 + i * 160 + 1, 400, 62, 70)
    end

    self.answerButtonList:draw()
end

function Waku:centerAnswerOptions()
    local max = self.answerOptionList:find_max(function(e)
        return e:getWidth()
    end)

    local width = _.min(max:getWidth(), self.maxTextWidth)

    self.answerOptionList(function(e)
        e.x = (WIDTH - width) / 2
        local ratio = _.min(1, self.maxTextWidth / max:getWidth())
        e.scale:set(ratio, ratio)
    end)

    self.answerOptionList(function(e)
    end)
end

function Waku:onFloorButtonPress(e, player)
    self:updateAnswerValue(e, player)
end

function Waku:updateAnswerValue(e, player)
    if not self.countDown then return end
    local cx = e:centerX() - self.scene.scene.map:getCurrentLevel().x
    local tag = player.tag:lower()

    if cx < WIDTH / 2 - 100 then
        self.answerValues[tag].standingOn = 1
    elseif cx > WIDTH / 2 + 100 then
        self.answerValues[tag].standingOn = 3
    else
        self.answerValues[tag].standingOn = 2
    end
end

function Waku:getNextQuestion()
    local position = self.questionCount % 12 -- Modulo 12 to find the position in the pattern
    local difficulty = 3

    if position == 1 or position == 2 or position == 8 or position == 9 then
        difficulty = 3
    elseif position == 3 or position == 7 or position == 10 then
        difficulty = 2
    elseif position == 5 then
        difficulty = 5
    elseif position == 6 or position == 0 then
        difficulty = 4
    elseif position == 11 then
        difficulty = 1
    end

    if self.points >= self.pointsRequired - 2 and difficulty < 4 then
        difficulty = 4
    end

    local special = false

    if position == 2 or position == 9 or position == 7
        or position == 0 or position == 4 or position == 11
        or position == 5 or position == 6 then
        special = true
    end

    if self.scene.scene.inWakuMinigame then
        special = false
    end

    local question
    local filtered_questions = _.filter(questions,
        function(q, i)
            return q.difficulty == difficulty
                and q.special == special
                and not self.seen[difficulty][i]
        end)

    if #filtered_questions == 0 then
        -- All special questions are gone
        filtered_questions = _.filter(questions,
            function(q, i)
                return q.difficulty == difficulty
                    and not self.seen[difficulty][i]
            end)
    end

    if #filtered_questions == 0 then
        self.seen[difficulty] = {}
        filtered_questions = _.filter(questions, function(q) return q.difficulty == difficulty end)
    end

    question = _.pick(filtered_questions)
    question.special = false
    local index = _.index_of(questions, question)
    self.seen[difficulty][index] = true

    return question
end

function Waku:nextQuestion()
    self.buttonStandedOnBeforeStart = {
        peter = self.answerValues.peter.standingOn,
        timon = self.answerValues.timon.standingOn
    }

    self.answerValues = {
        peter = { 0, 0, 0 },
        timon = { 0, 0, 0 },
    }

    self.chatPercentagesTexts(function(e)
        self:tween(e, .3, { alpha = 0 })
    end)

    self.alreadyActivatedLifeline = false

    self:resetClock()

    for i, v in ipairs(self.lifelineCooldowns) do
        self.lifelineCooldowns[i] = _.max(0, v - 1)
    end

    self.lifelineIcons(function(e, i)
        self:tween(e, .3, { alpha = self.lifelineCooldowns[i] == 0 and 1 or .5 })
    end)

    self:playAudio("next_question")
    self.questionCount = self.questionCount + 1

    local question = self:getNextQuestion()
    self.currentQuestion = question
    self.questionNumber:write("Vraag #" .. self.questionCount)
    self.questionText:write(question.question)

    self.questionNumber.alpha = 0
    self.questionText.alpha = 0

    local correct = question.answers[1]

    question.answers = _.shuffle(question.answers)

    question.correct = table.index_of(question.answers, correct)

    for i, v in ipairs(self.answerOptionList) do
        v:write(abc[i] .. ": " .. question.answers[i])
        v:setColor(255, 255, 255)
        v.offset.x = 0
        v.alpha = 0
    end

    self:centerAnswerOptions()

    for i, v in ipairs(self.answerOptionList) do
        v.x = v.x - 10
    end

    self.questionNumber.y = self.questionNumber.y + 10
    self.questionAlpha = 0
    self:tween(self.questionNumber, .3, { y = self.questionNumber.y - 10, alpha = 1 }):delay(1)
        :after(self.questionText, .3, { alpha = 1 }):delay(1)
        :after(self.answerOptionA, .3, { alpha = 1, x = self.answerOptionA.x + 10 }):delay(.5)
        :after(self.answerOptionB, .3, { alpha = 1, x = self.answerOptionB.x + 10 }):delay(.5)
        :after(self.answerOptionC, .3, { alpha = 1, x = self.answerOptionC.x + 10 }):delay(.5)
        :oncomplete(function()
            self.countDown = true
            self.scene.scene.music:play("computer/waku/" .. (_.mod(self.questionCount, 4)), nil, true)
        end)

    self.showSpecial = not self.showSpecial
    self.scene.scene.canPauseTheGame = false
end

function Waku:onAnsweringQuestion()
    self.scene.scene.canPauseTheGame = true

    self.countDown = false
    if self.client then
        self.client:close()
    end

    self.scene.scene.music:stop(4)
    local audio = self:playAudio("correct_answer")

    self:delay(audio:getDuration("seconds") + .5, function()
        local audio_abc = Asset.audio("sfx/computer/waku/answer_" .. abc[self.currentQuestion.correct])
        audio:setEffect("reverb")
        audio_abc:setVolume(CONFIG.defaultSFXVolume * SFX.maxVolume)
        audio_abc:play()
        local correctAnswerOption = self.answerOptionList[self.currentQuestion.correct]
        correctAnswerOption:setColor(100, 255, 100)
        self:tween(correctAnswerOption.offset, .3, { x = 10 })
        local wrongAnswers = self.answerOptionList:filter(function(e)
            return e ~= correctAnswerOption
        end)
        wrongAnswers:setAlpha(.5)
        local correct = 0
        for k, v in pairs(self.answerValues) do
            if v.standingOn == self.currentQuestion.correct then
                correct = correct + 1
                self.points = self.points + 1
                self.pointsIndividual[k] = self.pointsIndividual[k] + 1
            else
                self.points = self.points - 1
                self.pointsIndividual[k] = self.pointsIndividual[k] - 1
            end
        end

        self.points = _.max(0, self.points)

        self:delay(1.5, function()
            self.pointsText:write("Punten: " .. self.points .. "/" .. self.pointsRequired)
            self.pointsIndividualText:write({ { Colors("peter", true) }, self.pointsIndividual.peter, { 1, 1, 1 }, "/",
                { Colors("timon", true) }, self.pointsIndividual.timon })
            if correct == 2 then
                audio = self:playAudio("success")
            elseif correct == 0 then
                audio = self:playAudio("wrong")
            else
                audio = self:playAudio("same_points")
            end

            self:delay(audio:getDuration("seconds") + 1, function()
                if self.points >= self.pointsRequired then
                    self:onCompletingGame()
                else
                    self:nextQuestion()
                end
            end)
        end)
    end)
end

function Waku:generateAudioShuffles()
    self.audioNumberLists = {}

    local audioFiles = love.filesystem.getDirectoryItems("assets/audio/sfx/computer/waku")
    for k, v in ipairs(audioFiles) do
        local path = "assets/audio/sfx/computer/waku/" .. v
        if love.filesystem.getInfo(path, "directory") then
            local files = love.filesystem.getDirectoryItems(path)
            self.audioNumberLists[v] = _.shuffle(_.numbers(#files))
        end
    end
end

function Waku:playAudio(name)
    local t = self.audioNumberLists[name]
    local n = table.shift(t)
    table.insert(t, n)
    local audio = Asset.audio("sfx/computer/waku/" .. name .. "/" .. n)
    audio:setEffect("reverb")
    audio:setVolume(CONFIG.defaultSFXVolume * SFX.maxVolume)
    audio:play()
    return audio
end

function Waku:onButtonPress()
    if self:canUseLifeline() then
        self:initLifeline()
    end
end

function Waku:canUseLifeline()
    return self.countDown
end

function Waku:initLifeline()
    if self.alreadyActivatedLifeline then
        if self.lifelineMode then
            self:backToQuestion()
        end
        return
    end

    self.alreadyActivatedLifeline = true

    if not self:isLifelineAvailable() then
        self:playAudio("lifeline_no_available")
        return
    end

    self:playAudio("lifeline_which")

    self.lifelineMode = true

    self:resetClock()

    self.lifelineIconsBig(function(e, i)
        self:tween(e, .3, { alpha = self.lifelineCooldowns[i] == 0 and 1 or .5 })
    end)

    self.buttonStandedOnBeforeStart = {
        peter = self.answerValues.peter.standingOn,
        timon = self.answerValues.timon.standingOn
    }

    self.answerValues = {
        peter = { 0, 0, 0 },
        timon = { 0, 0, 0 },
    }

    self.answerButtonList(function(e, i)
        e:write(self.lifelineCooldowns[i] == 0 and "" or self.lifelineCooldowns[i])
    end)

    self.scene.scene.music:play("computer/neutral")
end

function Waku:backToQuestion()
    self:playAudio("lifeline_back")
    self.lifelineMode = false

    self:resetClock()

    self.scene.scene.music:play("computer/waku/" .. (_.mod(self.questionCount, 4)), nil, true)

    self.buttonStandedOnBeforeStart = {
        peter = self.answerValues.peter.standingOn,
        timon = self.answerValues.timon.standingOn
    }

    self.answerValues = {
        peter = { 0, 0, 0 },
        timon = { 0, 0, 0 },
    }

    self.answerButtonList(function(e, i)
        e:write(abc[i])
    end)

    self.lifelineIconsBig(function(e)
        self:tween(e, .3, { alpha = 0 })
    end)

    self:delay(.3, { countDown = true })
end

function Waku:isLifelineAvailable()
    return _.any(self.lifelineCooldowns, function(n)
        return n == 0
    end)
end

function Waku:onChoosingLifeline(i)
    self.lifelineCount = self.lifelineCount + 1
    self.scene.scene.music:stop(4)
    self.countDown = false
    self.lifelineCooldowns[i] = 11
    self.lifelineIcons[i].alpha = .5
    if i == 1 then
        local audio = self:playAudio("lifeline_fifty")
        self:delay(audio:getDuration("seconds") + .2, self.F:removeOneWrongAnswer())
            :after(.3, self.F:backToQuestion())
    elseif i == 2 then
        local audio = self:playAudio("lifeline_chat")
        self:initAskingChat()
        self:delay(audio:getDuration("seconds") + .2, self.F:startReceivingAnswersFromChat())
    elseif i == 3 then
        local audio = self:playAudio("lifeline_computer")
        self:delay(audio:getDuration("seconds") + .2, self.F:spoilCorrectAnswer())
            :after(.7, self.F:backToQuestion())
    end

    self:delay(2, function()
        self:tween(self.answerValues.peter, .3, { [1] = 0, [2] = 0, [3] = 0 })
        self:tween(self.answerValues.timon, .3, { [1] = 0, [2] = 0, [3] = 0 })
        self.answerValues.peter.filled = nil
        self.answerValues.timon.filled = nil
    end)
end

function Waku:removeOneWrongAnswer()
    local wrongAnswers = self.answerOptionList:filter(function(e)
        return e ~= self.answerOptionList[self.currentQuestion.correct]
    end)

    local wrongAnswer = table.shift(wrongAnswers)
    wrongAnswer:setAlpha(.5)
end

function Waku:askAudience()
end

function Waku:spoilCorrectAnswer()
    -- 50% chance of naming the correct answer
    local chance = _.chance(50)
    local answer = chance and self.currentQuestion.correct or _.pick(_.numbers(1, 3, { self.currentQuestion.correct }))
    local giveAnswer = self.answerOptionList[answer]

    giveAnswer:setColor(100, 100, 255)
    local audio = Asset.audio("sfx/computer/waku/answer_" .. abc[answer])
    audio:setEffect("reverb")
    audio:setVolume(CONFIG.defaultSFXVolume * SFX.maxVolume)
    audio:play()
end

function Waku:resetClock(time)
    self:tween(self, 1, { timer = time or 30 }):onupdate(function()
        self.clockTime:write(math.ceil(self.timer))
    end)
end

function Waku:initAskingChat()
    self:resetClock(5)
    self:connectWithChat()
    self.lifelineIconsBig(function(e)
        self:tween(e, .3, { alpha = 0 })
    end)

    self.chatPercentages = { 0, 0, 0 }

    self.chatPercentagesTexts(function(e)
        e:write("0%")
        self:tween(e, .3, { alpha = 1 })
    end)
    self.askingChat = true
end

function Waku:connectWithChat()
    self.seenChatters = {}
    self.switchToFakeTimer()
    if LEKKER_SPELEN then
        ---@diagnostic disable-next-line: missing-parameter
        self.client = websocket.new(SERVER_IP, 8082)

        ---@diagnostic disable-next-line: duplicate-set-field
        self.client.onmessage = function(c, message)
            local data = json.decode(message)
            if self.seenChatters[data.user] then
                return
            end

            local answer = self:extractAnswerFromMessage(data.message)

            if not answer then
                return
            end

            self.seenChatters[data.user] = true

            self.useFakeAudience = false
            self.switchToFakeTimer()
            self:onReceivingAudienceAnswer(answer)
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        self.client.onerror = function()
            self.client:close()
            self.client = nil
            self.useFakeAudience = true
        end

        ---@diagnostic disable-next-line: duplicate-set-field
        self.client.onclose = function()
            self.client = nil
        end
    else
        self.useFakeAudience = true
    end

    -- Find the 10 in the fakeAudienceWeighted and swap it with the value on the correct answer
    local correctAnswer = self.currentQuestion.correct
    local threeIndex = table.indexOf(self.fakeAudienceWeighted, 10)
    if correctAnswer == threeIndex then
        return
    end

    local value = self.fakeAudienceWeighted[correctAnswer]
    self.fakeAudienceWeighted[correctAnswer] = 10
    self.fakeAudienceWeighted[threeIndex] = value
end

function Waku:extractAnswerFromMessage(message)
    local answer = message:match("!?(%w)")
    if answer then
        return table.indexOf(abc, answer)
    end
    return nil
end

function Waku:startReceivingAnswersFromChat()
    self.countDown = true
end

function Waku:onReceivingAudienceAnswer(answer)
    if not self.countDown then return end
    self.chatPercentages[answer] = self.chatPercentages[answer] + 1
    local total = _.sum(self.chatPercentages)
    self.chatPercentagesTexts(function(e, i)
        e:write(math.floor(self.chatPercentages[i] / total * 100) .. "%")
    end)
end

function Waku:onBothFilled()
    if self.lifelineMode then
        if self.answerValues.peter.filled ~= self.answerValues.timon.filled then
            return
        end
        self:onChoosingLifeline(self.answerValues.peter.filled)
        return
    end

    self:onAnsweringQuestion()
end

function Waku:onTimeRunningOut()
    if self.lifelineMode then
        if not self.askingChat then
            if self.answerValues.peter.standingOn == self.answerValues.timon.standingOn then
                if self.answerValues.peter.standingOn ~= nil then
                    self:onChoosingLifeline(self.answerValues.peter.standingOn)
                    return
                end
            end
        end

        self:backToQuestion()
    else
        self:onAnsweringQuestion()
    end
end

function Waku:onCompletingGame()
    Save:set("game.waku.questions", self.questionCount)
    Save:set("game.waku.peter", self.pointsIndividual.peter)
    Save:set("game.waku.timon", self.pointsIndividual.timon)
    Save:set("game.waku.lifelines", self.lifelineCount)
    Save:save()

    self.scene.scene.music:play("computer/neutral", 2)
    local audio = Asset.audio("sfx/computer/waku/congratulations")
    audio:setEffect("reverb")
    audio:setVolume(CONFIG.defaultSFXVolume * SFX.maxVolume)
    audio:play()
    self:delay(audio:getDuration("seconds") + 1, function()
        self.scene:onCompletingWaku()
    end)
end

return Waku
